resource "aws_opensearch_domain" "search" {
    domain_name    = "${var.env}-daedong-search"
    engine_version = "OpenSearch_2.11"

    cluster_config {
        zone_awareness_enabled = false

        instance_type = "t3.small.search"
        instance_count = 1
    }

    ebs_options {
        ebs_enabled = true
        volume_type = "gp3"
        volume_size = 10
        iops = 3000
        throughput = 125
    }

    advanced_security_options {
        enabled                        = true
        anonymous_auth_enabled         = false
        internal_user_database_enabled = true
        master_user_options {
            master_user_name     = "${var.search_master_user_name}"
            master_user_password = "${var.search_master_user_password}"
        }
    }

    access_policies = data.aws_iam_policy_document.search.json

    domain_endpoint_options {
        custom_endpoint_enabled = false
        enforce_https       = true
        tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
    }

    node_to_node_encryption  {
        enabled = true
    }
    encrypt_at_rest {
        enabled = true
    }

    auto_tune_options {
        desired_state = "DISABLED"
        rollback_on_disable = "NO_ROLLBACK"
    }

    advanced_options = {
        "rest.action.multi.allow_explicit_index" = true
    }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "search" {
    statement {
        effect = "Allow"
        principals {
            type        = "AWS"
            identifiers = ["*"]
        }
        actions   = ["es:*"]
        resources = [
            "arn:aws:es:ap-northeast-2:${data.aws_caller_identity.current.account_id}:domain/${var.env}-daedong-search/*"
        ]
    }
}

resource "terraform_data" "default_index_template" {
    triggers_replace = [aws_opensearch_domain.search.id]
    depends_on = [aws_opensearch_domain.search]

    provisioner "local-exec" {
        command = <<EOT
        curl -X PUT "https://${aws_opensearch_domain.search.endpoint}/_template/default_template" -H 'Content-Type: application/json' -d'
        {
            "index_patterns": ["*"],
            "settings": {
                "number_of_shards": 1,
                "number_of_replicas": 0
            }
        }'
        EOT
    }
}
