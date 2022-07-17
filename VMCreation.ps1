$VMName = @("Server1","Server2","Server3","Server4","Server5")
$OSISO = Get-Item -Path B:\CentOS-8.3.2011-x86_64-dvd1.iso
$path = "A:\Vms"

foreach($VM in $VMName){
    New-VM -Name $VM -MemoryStartupBytes 1024MB -SwitchName external -NewVHDPath "$path\$VM\$VM.vhdx" -NewVHDSizeBytes 40GB -Path "$path\$VM" -Generation 2
    
    Add-VMDvdDrive -VMName $VM
    Set-VMDvdDrive -Path $OSISO.FullName -VMName $VM

    $DVD = Get-VMDvdDrive -VMName $VM
    $networkAdapater = Get-VMNetworkAdapter -VMName $VM
    $hdd = Get-VMHardDiskDrive -VMName $VM

    Set-VMFirmware -BootOrder $DVD, $hdd, $networkAdapater -VMName $VM
}

