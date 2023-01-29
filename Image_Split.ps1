<# - Base64Encode-NFT_Image

.SYNOPSIS
   Creates the _tokenURI from a single PNG image for the MoonPlace NFT

.DESCRIPTION
   Given the path of an image file, it'll create a txt file containing the base64-encoded _tokenURI that can be used to upload the image to MoonPlace's contract

.PARAMETER $Image_Path: File path of the PNG image
.PARAMETER $x:          x-coordinate of the tile
.PARAMETER $y:          y-coordinate of the tile

.OUTPUTS
   A text file of the _tokenURI output at location: $Image_Folder\$x, $y.txt

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
        if (-not $(Test-Path $Image_Path)) {
            Write-Host $("Can't find " + $Image_Path + "`'. Aborting script`n") -ForegroundColor Red
            exit
        }

        $Image_Folder = Split-Path -Path $Image_Path
    }
    Process
    {
        Write-Host $("Encoding: `'" + $Image_Path + "`'") -ForegroundColor Cyan
        # Write-Host "Position: [$x, $y]`n" -ForegroundColor Cyan

        # Convert image to base64
        $encoded_img = "data:image/png;base64," + [convert]::ToBase64String((get-content $Image_Path -encoding byte))

        # Add NFT metadata
        $NFT_JSON = "{`"title`":`"Moon Pixel Map`",`"description`":`"Block: ($x, $y)`",`"image`":`"$encoded_img`"}"
        
        # Convert to Bytes
        $encoded_NFT_JSON = [System.Text.Encoding]::UTF8.GetBytes($NFT_JSON)
        
        # Convert metadata to base64
        $encoded_NFT = "data:application/json;base64," + [convert]::ToBase64String($encoded_NFT_JSON)

        $encoded_NFT > "$Image_Folder\$x, $y.txt"

        Write-Host "File output: $Image_Folder\$x, $y.txt`n" -ForegroundColor Green
    }
    End
    {
    }
}




<# - NFT_Image_Split

.SYNOPSIS
   Breaks down a rectangular PNG image into many smaller PNG images

.DESCRIPTION
   Used for the MoonPlace NFT. It'll create separate 10x10 image files and generate _tokenURI txt files with their base64 code.
   
   You MUST use the FULL path of the image file, not just the relative path

   This also calls Base64Encode-NFT_Image to make _tokenURI files for them

.PARAMETER $Image_Path:  Absolute file path of the PNG image
.PARAMETER $Width:       Width of the original image in pixels
.PARAMETER $Height:      Height of the original image in pixels
.PARAMETER $X:           x-coordinate of the top-left tile
.PARAMETER $Y:           y-coordinate of the top-left tile

.OUTPUTS
   Multiple 10x10 .PNG images at $Image_Folder: $x, $y.png
   Multiple _tokenURL outputs in text files at $Image_Folder: $x, $y.txt

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
        if (-not $(Test-Path $Image_Path)) {
            Write-Host $("Can't find " + $Image_Path + "`'. Aborting script`n") -ForegroundColor Red
            exit
        }

        Write-Host $("Splitting image: `'" + $Image_Path + "`'`n") -ForegroundColor Cyan

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
NFT_Image_Split "C:\Location_Of_File\Original.png" -Width 20 -Height 40 -X 13 -Y 26