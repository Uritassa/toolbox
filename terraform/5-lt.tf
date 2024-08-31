resource "aws_launch_template" "main" {
    name                   = var.name
    update_default_version = true
    instance_type          = var.instance_type
    key_name               = var.key_name
    image_id               = var.ami
    ebs_optimized          = true

    iam_instance_profile {
        name = aws_iam_instance_profile.instance_profile.name
    }

    monitoring {
        enabled = true
    }

    network_interfaces {
        associate_public_ip_address = true
        security_groups              = [aws_security_group.main.id]
    }

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = var.name
        }
    }

    metadata_options {
        http_endpoint               = "enabled"
        http_put_response_hop_limit = 1
        http_tokens                 = "optional"
        instance_metadata_tags      = "enabled"
    }

    instance_market_options {
        market_type = "spot"

    }

    #example
    user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install python3 python3-pip python3-venv nginx -y
    mkdir -p /home/admin/my_flask_app
    cd /home/admin/my_flask_app

    # Create Flask app
    cat << 'EOL' > app.py
    from flask import Flask, abort
    from random import random

    app = Flask(__name__)

    @app.route('/get-data')
    def get_data():
        if random() < 0.2:
            return 'your data...'
        else:
            abort(501, 'Server failed due to an internal error')

    @app.route('/')
    def index():
        return '##############simple_flask##############\n'

    if __name__ == '__main__':
        app.run(debug=True, port=8080, host='0.0.0.0')
    EOL

    # Nginx configuration
    sudo rm /etc/nginx/sites-enabled/default
    sudo bash -c 'cat << EOL > /etc/nginx/sites-available/flask_app
    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
    EOL'

    sudo ln -s /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl restart nginx
    sudo python3 -m venv venv
    source venv/bin/activate
    pip install Flask
    nohup python3 app.py > my_flask_app.log 2>&1 &
    EOF
    )

    block_device_mappings {
        device_name = "/dev/sda1"
        ebs {
            volume_size          = 20
            delete_on_termination = true
            volume_type           = "gp3"
        }
    }
}
