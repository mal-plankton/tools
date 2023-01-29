<#
.SYNOPSIS
   Creates the _tokenURI from a single PNG image for the MoonPlace NFT

.DESCRIPTION
   Given the path of an image file, it'll create a txt file containing the base64-encoded _tokenURI that can be used to upload the image to MoonPlace's contract

.Parameter 1: File path of the PNG image
.Parameter 2: x-coordinate of the tile
.Parameter 3: y-coordinate of the tile

.EXAMPLE
   Base64Encode-NFT_Image ".\Image_Name.png" -x 15 -y 20
#>
function Base64Encode-NFT_Image
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # Image file path
        [Parameter(Mandatory=$true)]
        [string]$Image_Path,

        [Parameter(Mandatory=$true)]
        # Tile x-coordinate
        [int] $x,

        [Parameter(Mandatory=$true)]
        # Tile y-coordinate
        [int] $y
    )

    Begin
    {
        $Image_Folder = Split-Path -Path $Image_Path
    }
    Process
    {
        Write-Host $("Encoding: `'" + $Image_Path + "`'") -ForegroundColor Cyan
        Write-Host "Position: [$x, $y]`n" -ForegroundColor Cyan

        # Convert image to base64
        $encoded_img = "data:image/png;base64," + [convert]::ToBase64String((get-content $Image_Path -encoding byte))

        # Add NFT metadata
        $NFT_JSON = "{`"title`":`"Moon Pixel Map`",`"description`":`"Block: ($x, $y)`",`"image`":`"$encoded_img`"}"
        
        # Convert to Bytes
        $encoded_NFT_JSON = [System.Text.Encoding]::UTF8.GetBytes($NFT_JSON)
        
        # Convert metadata to base64
        $encoded_NFT = "data:application/json;base64," + [convert]::ToBase64String($encoded_NFT_JSON)

        $encoded_NFT > "$Image_Folder\$x, $y.txt"
    }
    End
    {
    }
}




<#
.SYNOPSIS
   Breaks down a rectangular PNG image into many smaller PNG images

.DESCRIPTION
   Used for the MoonPlace NFT. It'll create separate 10x10 image files and generate _tokenURI txt files with their base64 code.
   
   You MUST use the FULL path of the image file, not just the relative path

   This also calls Base64Encode-NFT_Image to make _tokenURI files for them

.Parameter 1: File path of the PNG image
.Parameter 2: Width of the original image in pixels
.Parameter 3: Height of the original image in pixels
.Parameter 3: x-coordinate of the top-left tile
.Parameter 3: y-coordinate of the top-left tile

.EXAMPLE
   NFT_Image_Split "C:\Location_Of_File\Original.png" -Width 40 -Height 40 -X 6 -Y 30
#>
function NFT_Image_Split
{
    [CmdletBinding()]
    Param
    (
        # Image file path
        [Parameter(Mandatory=$true)]
        [string] $Image_Path,

        # Width of Image
        [Parameter(Mandatory=$true)]
        [int] $Width,

        # Height of Image
        [Parameter(Mandatory=$true)]
        [int] $Height,

        [Parameter(Mandatory=$true)]
        # X-coordinate of Top-Left Tile
        [int] $X,

        [Parameter(Mandatory=$true)]
        # Y-coordinate of Top-Left Tile
        [int] $Y
    )

    Begin
    {
        Write-Host $("Splitting image: `'" + $Image_Path + "`'") -ForegroundColor Cyan

        # Size of each smaller split image
        $Size = 10

        $Image_Folder = Split-Path -Path $Image_Path
    }
    Process
    {
        
        $bmp  = New-Object System.Drawing.Bitmap($Image_Path)

        
        # Iterate through Widths
        for($i=0; $i -lt $width; $i += $Size) {
            
            # Iterate through Height
            for($j=0; $j -lt $Height; $j += $Size) {

                $rect = New-Object System.Drawing.Rectangle($i, $j, $Size, $Size) # top, left, width, height of slice

                $slice = $bmp.Clone($rect, $bmp.PixelFormat)

                # Save the image slices
                $slice.Save("$Image_Folder\$($i/10), $($j/10).png", "png");

                # Create Base64-encoded version of those images
                Base64Encode-NFT_Image "$Image_Folder\$($i/10), $($j/10).png" -x $($i/10 + $X) -y $($j/10 + $Y)
            }
        }
        
    }
    End
    {
    }
}


## This is an example
NFT_Image_Split "C:\Location_Of_File\Original.png" -Width 40 -Height 40 -X 6 -Y 30
