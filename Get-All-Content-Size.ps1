# Set Jive API credentials  
$JiveUsername = "your_jive_username"  
$JivePassword = "your_jive_password"  
  
# Set Jive API base URL  
$JiveBaseUrl = "https://your_jive_instance_base_url/api/core/v3"  
  
# Function to call Jive API  
function Invoke-JiveApiRequest {  
    param (  
        [string] $Uri,  
        [string] $Username,  
        [string] $Password  
    )  
      
    $credentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)"))  
  
    $headers = @{  
        "Authorization" = "Basic $credentials"  
    }  
  
    try {  
        $response = Invoke-WebRequest -Uri $Uri -Headers $headers -ContentType "application/json" -Method Get  
        return $response.Content  
    }  
    catch {  
        Write-Error $_.Exception.Message  
        return $null  
    }  
}  
  
# Function to get content size of different content types in Jive  
function Get-JiveContentSize {  
    param (  
        [string] $BaseUrl,  
        [string] $Username,  
        [string] $Password,  
        [string] $ContentType  
    )  
  
    $nextPageUrl = "$BaseUrl/contents?filter=type($ContentType)&count=100"
    if($ContentType -eq "post") {
        $nextPageUrl += "&includeBlogs=true"
    }
    $totalContentSize = 0  
  
    while ($nextPageUrl -ne $null) {  
        $responseContent = Invoke-JiveApiRequest -Uri $nextPageUrl -Username $Username -Password $Password  
  
        if ($responseContent -ne $null) {  
            $responseJson = $responseContent | ConvertFrom-Json  
            $nextPageUrl = $responseJson.links.next  
  
            foreach ($content in $responseJson.list) {  
                $totalContentSize += $content.size  
            }  
        }  
        else {  
            $nextPageUrl = $null  
        }  
    }  
  
    return $totalContentSize  
}  

<#
discussion (Discussion) - a discussion, which is the beginning of a conversation.
document (Document) - a document in Jive that can be discussed and shared with other people.
favorite (Favorite) - a link to content around the web that can be shared and discussed.
file (File) - a file in Jive that can be discussed and shared with other people.
poll (Poll) - a poll where people can vote to make a decision or express an opinion.
post (Post) - an entry in a blog.
slide (Slide) - an entry in a Carousel.
task (Task) - a task for a person to get things done.
update (Update) - a user status update.
#>
  
# Define content types  
$contentTypes = @("discussion","file","document","favorite","poll","post","slide","task","update")
  
# Call the function to get the content size for each content type in Jive  
foreach ($contentType in $contentTypes) {  
    $totalContentSize = Get-JiveContentSize -BaseUrl $JiveBaseUrl -Username $JiveUsername -Password $JivePassword -ContentType $contentType  
    Write-Host "Total content size for $contentType in Jive: $totalContentSize bytes"  
}  
