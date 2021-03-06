function Write-PowerShellHashtable {
    <#
    .Synopsis
        Takes an creates a script to recreate a hashtable
    .Description
        Allows you to take a hashtable and create a hashtable you would embed into a script.
        
        Handles nested hashtables and indents nested hashtables automatically.
    .Parameter inputObject
        The hashtable to turn into a script
    .Parameter scriptBlock
        Determines if a string or a scriptblock is returned
    .Example
        # Corrects the presentation of a PowerShell hashtable
        @{Foo='Bar';Baz='Bing';Boo=@{Bam='Blang'}} | Write-PowerShellHashtable
    .ReturnValue
        [string]
    .ReturnValue
        [ScriptBlock]   
    .Link
        about_hash_tables
    #>    
    param(
    [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [PSObject]
    $InputObject,

    # Returns the content as a script block, rather than a string
    [switch]$scriptBlock
    )

    process {
        $callstack = @(Get-PSCallStack | 
            Where-Object { $_.Command -eq "Write-PowerShellHashtable"})
        $depth = $callStack.Count
        if ($inputObject -is [Hashtable]) {
            $scriptString = ""
            $indent = $depth * 4        
            $scriptString+= "@{
"
            foreach ($kv in $inputObject.GetEnumerator()) {
                $indent = ($depth + 1) * 4
                for($i=0;$i -lt $indent; $i++) {
                    $scriptString+=" "
                }
                $keyString = $kv.Key
                
                $scriptString+="'$($kv.Key)'="
                
                
                $value = $kv.Value
                Write-Verbose "$value"
                if ($value -is [string]) {
                    $value = "'"  + $value.Replace("'","''").Replace("’", "’’").Replace("‘", "‘‘") + "'"
                } elseif ($value -is [ScriptBlock]) {
                    $value = "{$value}"
                } elseif ($value -is [switch]) {
                    $value = if ($value) { '$true'} else { '$false' }
                } elseif ($value -is [bool]) {
                    $value = if ($value) { '$true'} else { '$false' }
                } elseif ($value -is [Object[]]) {
                    $oldOfs = $ofs 
                    $ofs = "',
$(' ' * ($indent + 4))'"
                    $value = "'$value'"
                    $ofs = $oldOfs
                } elseif ($value -is [Hashtable]) {
                    $value = "$(Write-PowerShellHashtable $value)"
                } else {
                    $value = "'$value'"
                }                                
               $scriptString+="$value
"
            }
            $indent = $depth * 4
            for($i=0;$i -lt $indent; $i++) {
                $scriptString+=" "
            }          
            $scriptString+= "}"     
            if ($scriptBlock) {
                [ScriptBlock]::Create($scriptString)
            } else {
                $scriptString
            }
        }           
   }
}         
