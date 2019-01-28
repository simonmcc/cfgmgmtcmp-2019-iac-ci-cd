all: base app

base: manifest-base.json
app: manifest-app.json

.PHONY: packer-vpc
packer-vpc:
	cd packer-vpc ; terraform init ; terraform apply -auto-approve

.PHONY: packer-vpc-clean
packer-vpc-clean:
	cd packer-vpc ; terraform destroy -auto-approve
	@rm -f packer-vpc/terraform.tfstate

manifest-base.json: packer-vpc Makefile $(shell find base/ -type f)
	packer validate ./base/base.json
	./scripts/build.sh base base

manifest-app.json: packer-vpc manifest-base.json Makefile $(shell find app/ -type f)
	packer validate ./app/app.json
	./scripts/build.sh app app base

clean:
	./scripts/clean.sh base base
	./scripts/clean.sh app app


#AMI_BASE=ami-fakefake packer validate app/app.json"
#terraform fmt
#./scripts/build.sh base base"
#./scripts/build.sh app app"
#./scripts/tf-wrapper.sh -a plan"
#./scripts/tf-wrapper.sh -a apply"
