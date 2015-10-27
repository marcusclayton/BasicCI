Describe "Server Is Up" {
    $ServerHostIp = '10.83.182.28'
    $ServerHostname = 'Local529'

    Context "SQL" {
        $SqlDbs = Remotely { Get-SqlDatabase -Path SQLServer:\sql\Local529\Default\Databases\MSPetShop4\ | ? {$_.Name -like 'MSPetShop4*'} }
        It "SQL databases exist" {
            $SqlDbs | Should Not BeNullOrEmpty
        }
        It "has a working MSPetShop4" {
            $myDB = $SqlDbs | ? {$_.Name -like 'MSPetShop4'}
            $myDb.Status | Should Be 'Normal'
        }
        It "has a working MSPetShop4Orders" {
            $myDB = $SqlDbs | ? {$_.Name -like 'MSPetShop4Orders'}
            $myDb.Status | Should Be 'Normal'
        }
        It "has a working MSPetShop4Profile" {
            $myDB = $SqlDbs | ? {$_.Name -like 'MSPetShop4Profile'}
            $myDb.Status | Should Be 'Normal'
        }
        It "has a working MSPetShop4Services" {
            $myDB = $SqlDbs | ? {$_.Name -like 'MSPetShop4Services'}
            $myDb.Status | Should Be 'Normal'
        }
    }
    Context "Web Server" {
        It "accepts a TCP connection on port 80" {
            $testNetConnectionResults = Test-NetConnection -ComputerName $ServerHostIp -Port 80
            $testNetConnectionResults.TcpTestSucceeded | Should Be $true
        }
        
        $actualHomepage = Invoke-WebRequest $ServerHostIp
        It "returns a good error code" {
            $actualHomepage.StatusCode | Should Be 200
        }
        It "has the right homepage" {
            $correctHomepage = Import-CliXml $PSScriptRoot\correctHomepage.xml
            $result = Compare-Object $correctHomepage $actualHomepage
            Compare-Object $correctHomepage.Content $actualHomepage.Content | Should BeNullOrEmpty
        }

        It "has all the backyard animals" {
            $actualBackyard = Invoke-WebRequest "$ServerHostIp/Products.aspx?page=0&categoryId=BYARD"
            $correctBackyard = Import-CliXml $PSScriptRoot\correctBackyard.xml
            Compare-Object $correctBackyard.Content $actualBackyard.Content | Should BeNullOrEmpty
        }
        It 'is selling pandas for $1,999 each' {
            $actualPanda = Invoke-WebRequest "$ServerHostIp/Items.aspx?productId=DR-04&categoryId=EDANGER"
            $actualPanda.Content -like '*$1,999*' | Should Be $true
        
        }
    }
}