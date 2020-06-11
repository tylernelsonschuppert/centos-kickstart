Function New-LinuxVM {
  Param(
    [Parameter(Mandatory=$True)]
    [string]$Name
  )
  New-VM -Name "$Name" -NumCpu 2 -MemoryGB 4 -VMHost 192.168.1.25 -Datastore HGST -DiskGB 20
  $networkAdapter = Get-NetworkAdapter -VM $Name -Name "Network Adapter 1"
  Remove-NetworkAdapter -NetworkAdapter $networkAdapter -Confirm:$false
  Get-VM $Name | New-NetworkAdapter -NetworkName "Kickstart Project - VLAN50 - 192.168.5.0/24" -Type VMXNET3 -StartConnected
  Get-ScsiController -VM $Name | Set-ScsiController -Type ParaVirtual
  Get-VM -Name $Name | Set-VM -GuestId centos8_64Guest -Confirm:$false
  $vm = Get-VM $Name
  $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
  $spec.Firmware = [VMware.Vim.GuestOsDescriptorFirmwareType]::bios
  $vm.ExtensionData.ReconfigVM($spec)
  Start-VM $Name
}
