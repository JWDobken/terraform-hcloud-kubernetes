# Demo kubernetes cluster

From the [Hetzner Cloud portal](https://console.hetzner.cloud/projects), create a new project and select it. Go to "Security" > "API Tokens" > "Generate API Token" and create a token with *Read & Write* permissions and copy the token.

There are a couple of options to pass the token, but you can create an environmental variable:
```
export TF_VAR_hcloud_token="tBho3vJzmloeywgIRy62NoRygPKdu2c0klXQ9JCvjyEbALwwna2tpSzrsf2yb8o9"
```

Now, change the settings in the file `demo.tfvars`. Make sure the path to the SSH public key is correct and the private key is added to your keychain.

Now run:

```cmd
terraform init .
terraform plan -var-file="demo.tfvars" -out "demo.tfplan" .
terraform apply -input=false "demo.tfplan"
```

You can destroy the created resources with:

```cmd
terraform destroy -var-file="demo.tfvars"
```
