Facter.add("nlb_member_ip") do
  confine :osfamily => "windows"
  ip = Facter.value(:ipaddress)
  setcode do
    powershell = 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe'
    command = "(Get-WmiObject win32_networkadapterconfiguration | where { $_.IPAddress -like '#{ip}' }).IpAddress | where { $_ -notlike 'fe80*' } | where { $_ -notlike '#{ip}' }"
    query=Facter::Util::Resolution.exec(%Q{#{powershell} -command "#{command}"})
    query=query.strip
  end
end
