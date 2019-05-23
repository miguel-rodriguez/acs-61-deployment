. ~/.nexus-cfg
packer build -var-file=vars-61.json -on-error=ask packer-template-transform-service.json
