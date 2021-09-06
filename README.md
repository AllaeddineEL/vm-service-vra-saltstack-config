# vSphere VM Service automation with vRealize Automation SaltStack Config
This repo holds a collection of terraform scripts and other resources to show how you can use [vSphere with Tanzu VM Services](https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-F81E3535-C275-4DDE-B35F-CE759EA3B4A0.html) and [vRealize Automation SaltStack Config](https://docs.vmware.com/en/VMware-vRealize-Automation-SaltStack-Config/index.html) together to deliver automated  deployment for vm-based workloads in cloud-native way.


Prerequisites
-------------
### * Create an Customer Connect profile
If you don't have a [Customer Connect profile](https://customerconnect.vmware.com/), you can sign up for a new one [here](https://customerconnect.vmware.com/account-registration). To download 

### * A vSphere with Tanzu VM Service Environment

Please refer to vSphere with Tanzu VM Service [documentation](https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-F81E3535-C275-4DDE-B35F-CE759EA3B4A0.html) for more information. 


### * Install Terraform if it's not installed yet

Now, we need to install Terraform.  Instructions on that are [here](https://www.terraform.io/intro/getting-started/install.html).  Depending on which OS you run the installation is slightly different:

<details><summary>macOS</summary>

The easiest way is to install [brew](https://brew.sh/) and then used it to install Terraform with the commands:

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
sudo chown -R $(whoami) /usr/local/bin /usr/local/lib
brew install terraform
```

</details>

<details><summary>Linux</summary>

For installing on Linux, just run:

```
VERSION='0.11.10' # latest, stable version
wget "https://releases.hashicorp.com/terraform/"$VERSION"/terraform_"$VERSION"_linux_amd64.zip"
unzip terraform_0.11.10_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo chown root:root /usr/local/bin/terraform
```

</details>

<details><summary>Windows</summary>

The easiest way to install Terraform and run other setup is to install [Chocolatey](https://chocolatey.org/), which is a package manager for windows.
You can then use Chocolatey to install Terraform and Git for Windows (which includes other needed tools).

Start powershell **as Administrator** and run the commands below. `choco` will prompt to install, press `Y` and enter.

```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install terraform
choco install git.install --params "/GitAndUnixToolsOnPath /NoAutoCrlf"
```

After this completes close this powershell. These commands have installed Terraform, git, and other utilities we'll use later.

</details>

Dependencies
------------

1. Download the **VMware vRealize Automation SaltStack Config 8.5 virtual appliance** from customer connect [here](https://customerconnect.vmware.com/downloads/details?downloadGroup=VRA-SSC-850&productId=1184&rPId=70960)
2. Download and unzip the **VMware vRealize Automation SaltStack SecOps License** from customer connect [here](https://customerconnect.vmware.com/downloads/details?downloadGroup=VRA-SSSO-840&productId=1184&rPId=70960). For more details click [here](https://docs.vmware.com/en/VMware-vRealize-Automation-SaltStack-Config/8.5/install-configure-saltstack-config/GUID-39650C9F-E343-4CDF-9E1E-1A0DFFDFAF61.html)
3. Place the downloaded and the extracted files into [artifacts](artifacts) folder