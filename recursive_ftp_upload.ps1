# $ftp_user -> duh!
# $ftp_pass -> duh!
# $local_full_base_path -> Full local file path. e.g. C:\Users\john\devfiles\my_wordpress_theme
#   DO NOT USE A BACKSLASH AS LAST CHARACTER IN THE FULL LOCAL BASE PATH. Not tested, sorry.
# $ftp_base_path -> Full path in the FTP location, including the server addres. e.g. ftp://ftp.myfancyaddress.com/htdocs/wp-content/themes/my_wordpress_theme
#   DO NOT USE A BACKSLASH AS LAST CHARACTER IN THE FULL FTP BASE PATH TOO. Also not tested, sorry.

Function upload_ftp_recursive($ftp_user, $ftp_pass, $local_full_base_path, $ftp_base_path) {

    $ftp_client = New-Object System.Net.WebClient
    $ftp_credentials = New-Object System.Net.NetworkCredential($ftp_user, $ftp_pass)

    $ftp_client.Credentials = $ftp_credentials

    $listFiles = Get-ChildItem $local_full_base_path -recurse
    foreach($file in $listFiles) {

        if ($file.Directory) {
            $file_full_path_dslash = $file.FullName -replace "\\","\\"
            $local_full_base_path_dslash = $local_full_base_path -replace "\\","\\"
            $file_path_from_base = $file.FullName -replace $local_full_base_path_dslash,""
            $file_path_from_base_islash = $file_path_from_base -replace "\\","/"
            $ftp_full_path_destiny = $ftp_base_path + $file_path_from_base_islash
            $folder_arrs = $file_path_from_base_islash -split "/"

            try {
                $uri = New-Object System.Uri($ftp_full_path_destiny)
                $ftp_client.UploadFile($uri, $file.FullName);
                Write-Host Successful uploaded: $file.FullName -> $ftp_full_path_destiny
            } catch {
                $base_creation_string = ""
                for ($i = 1; $i -lt $folder_arrs.Length - 1; $i++) {
                    $base_creation_string += $folder_arrs[$i] + "/"
                    $folder_to_be_created = $ftp_base_path + "/" + $base_creation_string

                    $ftp_client_creation_dir = [System.Net.FtpWebRequest]::Create($folder_to_be_created)
                    $ftp_client_creation_dir.Credentials = $ftp_credentials
                    $ftp_client_creation_dir.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
                    
                    Write-Host File dir: $file.Directory
                    try {
                        $ftp_client_creation_dir.GetResponse()
                        $ftp_client.UploadFile($uri, $file.FullName);
                    } catch {
                        # Some output to analyse whats going on if something got wrong (still not happened with me!)
                        Write-Host "---"
                        Write-Host Error!
                        Write-Host File full name: $file.FullName
                        Write-Host FTP folder: $ftp_full_path_destiny
                        Write-Host File dir: $file.Directory
                    }
                }
            }
        }
    }
}