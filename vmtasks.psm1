function New-ProdVirtualMachine{
 [CmdletBinding()]

    Param(
    
       [parameter(Mandatory,ParameterSetName="ProdvCenter")]
       [string]
       $ProdvCenter,
       
       [parameter(Mandatory,ValueFromPipeline)]
       [string[]]
       $VMName,
       
       [parameter(Mandatory,ParameterSetName="ProdvCenter")]
       [string]
       $ProdTemplate,
       
       [parameter(Mandatory,ParameterSetName="ProdvCenter")]
       [string]
       $ProdDatastore,

       [parameter(Mandatory,ParameterSetName="ProdvCenter")]
       [string]
       $ResourcePool,
       
       [parameter(Mandatory,ParameterSetName="ProdvCenter")]
       [string]
       $ProdCustom
          
    )


#Credentials for vcenter login and customization
$creds = Get-Credential
$User = $creds.UserName
$Password = $creds.Password
$VIcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Password
try{
        Connect-VIServer $ProdvCenter -Credential $VIcred -ErrorAction Stop
        }
        Catch{Write-Warning "Username or Password are Incorrect"
        }

 
#Sets credentials for the "Join to the Domain" section in the VM Guest Customization specified in the CSV. You will be prompted to input your credentals.
        Set-OSCustomizationSpec $ProdCustom -DomainUsername $creds.GetNetworkCredential().UserName -DomainPassword $creds.GetNetworkCredential().Password
    
 #Building VMs
foreach ($vm in $VMName){

        New-VM -Name $VM -Template $ProdTemplate -ResourcePool $ResourcePool  -StorageFormat Thick -Datastore $ProdDatastore -OSCustomizationSpec $ProdCustom
               Function Enable-MemHotAdd($vm){
               $vmview = Get-vm $vm | Get-View
               $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
               $extra = New-Object VMware.Vim.optionvalue
               $extra.Key="mem.hotadd"
               $extra.Value="true"
               $vmConfigSpec.extraconfig += $extra
               $vmview.ReconfigVM($vmConfigSpec)
}
       Enable-MemHotAdd($vm)
               
               Function Enable-vCpuHotAdd($vm){
               $vmview = Get-vm $vm | Get-View
               $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
               $extra = New-Object VMware.Vim.optionvalue
               $extra.Key="vcpu.hotadd"
               $extra.Value="true"
               $vmConfigSpec.extraconfig += $extra
               $vmview.ReconfigVM($vmConfigSpec)
}#
#       Enable-vCpuHotAdd($vm)
        sleep -Seconds 10
   

Start-VM -VM $VM

    }

#Re-sets credentials for the "Join to the Domain" section for the VM Guest Customization.
Set-OSCustomizationSpec $ProdCustom -DomainUsername example -DomainPassword dkdji49sksjdj

}


function New-DRVirtualMachine{
 [CmdletBinding()]

    Param(
          
       [parameter(Mandatory,ParameterSetName="DRvCenter")]
       [string]
       $DRvCenter,
       
       [parameter(Mandatory,ValueFromPipeline)]
       [string[]]
       $VMName,
       
       [parameter(Mandatory,ParameterSetName="DRvCenter")]
       [string]
       $DRTemplate,
       
       [parameter(Mandatory,ParameterSetName="DRvCenter")]
       [string]
       $DRDatastore,

       [parameter(Mandatory,ParameterSetName="DRvCenter")]
       [string]
       $ResourcePool,

       [parameter(Mandatory,ParameterSetName="DRvCenter")]
       [string]
       $DRCustom
   )

#Credentials for vcenter login and customization
$creds = Get-Credential
$User = $creds.UserName
$Password = $creds.Password
$VIcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Password
try{
        Connect-VIServer $DRvCenter -Credential $VIcred -ErrorAction Stop
        }
        Catch{Write-Warning "Username or Password are Incorrect"
        }


#Sets credentials for the "Join to the Domain" section in the VM Guest Customization specified in the CSV. You will be prompted to input your credentals.
        Set-OSCustomizationSpec $DRCustom -DomainUsername $creds.GetNetworkCredential().UserName -DomainPassword $creds.GetNetworkCredential().Password
 

#Building VMs
foreach ($vm in $VMName){

        New-VM -Name $VM -Template $DRTemplate -ResourcePool $ResourcePool  -StorageFormat Thick -Datastore $DRDatastore -OSCustomizationSpec $DRCustom
        
        Function Enable-MemHotAdd($vm){
$vmview = Get-vm $vm | Get-View
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$extra = New-Object VMware.Vim.optionvalue
$extra.Key="mem.hotadd"
$extra.Value="true"
$vmConfigSpec.extraconfig += $extra
$vmview.ReconfigVM($vmConfigSpec)
}
        
        
        Enable-MemHotAdd($vm)


Function Enable-vCpuHotAdd($vm){
$vmview = Get-vm $vm | Get-View
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$extra = New-Object VMware.Vim.optionvalue
$extra.Key="vcpu.hotadd"
$extra.Value="true"
$vmConfigSpec.extraconfig += $extra
$vmview.ReconfigVM($vmConfigSpec)
}



        Enable-vCpuHotAdd($vm)

        Start-Sleep -Seconds 10

    Start-VM -VM $VM
    
    }

#Re-sets credentials for the "Join to the Domain" section for the VM Guest Customization.
Set-OSCustomizationSpec $DRCustom -DomainUsername example -DomainPassword dkdji49sksjdj
}

Function Remove-VirtualMachine{
    [cmdletbinding(SupportsShouldProcess,ConfirmImpact = "High")]

        Param(
        [parameter(Mandatory)]
        [String[]]
        $computername,
        [parameter(Mandatory)]
        [string]
        $vcenter         
        )

    
#Credentials for vcenter login and customization
$creds = Get-Credential
$User = $creds.UserName
$Password = $creds.Password
$VIcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Password
try{
        Connect-VIServer $vcenter -Credential $VIcred -ErrorAction Stop
        }
        Catch{Write-Warning "Username or Password are Incorrect"
        }

Get-VM $computername | Stop-VM | Remove-VM -DeletePermanently

}

Function Get-VMHostInfo{

    Param(
        [parameter(Mandatory)]
        [string[]]
        $vcenter         
        )

Connect-VIServer $vcenter

Get-vmhost -Server $vcenter | ft Name,Version,Build

}
