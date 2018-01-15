# set up gcp host

- specify vars in "terraform.tfvars" and  override defaults  from variables.tf
- terraform init
- terrafrom plan
- terraform apply

# provision instance with docker-machine

```docker-machine create \
    --driver generic \
    --generic-ip-address=${ip} \
    --generic-ssh-user=gitlab \
    --generic-ssh-key ~/.ssh/id_rsa \
    gitlab-host
```

# optionaly set docker-machine env
eval $(docker-machine env gitlab-host)
 or use
docker-machine ssh gitlab-host

# export gitlab-host variable

```export GITLAB_HOST_IP=$(docker-machine ip gitlab-host)```

# run gitlab and create group, project and

```cd gitlab
docker-compose up -d ci
```

# get a token from project -> setting -> CI/CD - > Runner

# run container registration

```docker-compose -f docker-compose.yml -f docker-compose.regrunner.yml up register```

# satart runner itself

```docker-compose up -d```

Your are all set
