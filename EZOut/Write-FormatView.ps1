function Write-FormatView
{
    <#
    .Synopsis
        Creates a format XML that will be used to display a type.                
    .Description
        Creates a format XML that will be used to display a type.
        
        Format XML is used by Windows PowerShell to determine how objects are displayed.
        
        Most items in PowerShell that come from built-in cmdlets make use of formatters in some
        way or another.  Write-FormatView simplifies the creation of formatting for a type.
        
        
        You can format information in three major ways in PowerShell:
            - As a table
            - As a list
            - As a custom action
            
        Write-FormatView supports displaying information in any of these ways.  This display
        will be applied to any information that would be displayed to the user (or piped into 
        an Out- cmdlet) that has the typename you specify.  A typename can be anything you like,
        and it can be set in a short piece of PowerShell script:
            
            $object.psObject.Typenames.Clear()
            $null = $object.psObject.TypeNames.Add("MyTypeName").
        
        Since it is so simple to change the type names, it's equally simple to make your own way to 
        display data, and to write functions that leverage the formatting system in PowerShell to help
        you write the information.  This can streamline your use of PowerShell, and open up many
        new possibilities.        
    .Outputs 
        [string]
    .Link 
        Out-FormatData
    .Link 
        Add-FormatData            
    .Example
        # One of the simple ways you can use Write-FormatView and the rest of this module is to improve your 
        # interaction with pieces of data that you normally use in PowerShell, but find difficult to read.

        # By using Write-FormatView, you can create a new look and feel for a type in PowerShell.

        # A great example is the WMI class Win32_VideoController.  By default, no view is defined, so
        # when you run

        Get-WmiObject Win32_VideoController

        # You get every property that exists on the video controller class, which is, well, a lot.
        # One simple way to improve the experience is to make it a limited number of properties.

        # To do this, we need to find out the type name.  You can see the type name at the top of
        # the output of Get-Member
        Get-WmiObject Win32_VideoController | 
            Get-Member

        # Since everything is an object in PowerShell, we can pick out just the typename property from
        # the result of Get-Member, and use this in the rest of the examples.  
        # This trick will work for any single type of object that comes out of any command.
        $typeName = 
            Get-WmiObject Win32_VideoController | 
                Get-Member |
                Select-Object -ExpandProperty TypeName -Unique

        # The first way we can try improving the look and feel is to display a fixed set of properties.
        # I'm interested in discovering the name, the ram, and the resolution.  To write a piece of format XML
        # that can be used to display just these few properties, we just need to write this one line:
        Write-FormatView -TypeName $typeName -Property Name, AdapterRAM, VideoModeDescription


        # When this command is run, a bunch of text is outputted.  This text can be used as part of a larger 
        # format.ps1xml file you write, or you can join this and other views into a file with Out-FormatData.
        # If pipe Out-FormatData into Add-FormatData, you can dynamically add views to the output of anything
        # in PowerShell.
        Write-FormatView -TypeName $typeName -Property Name, AdapterRAM, VideoModeDescription |
            Out-FormatData |
            Add-FormatData
            
        # Now let's see how it looks
        Get-WmiObject Win32_VideoController
                
        # As we continue, we'll be able to make this much nicer and richer.

        # First, let's do the easy thing, and AutoSize the whole table.  
        # This can be done to any table view with the -AutoSize switch
        Write-FormatView -TypeName $typeName -Property Name, AdapterRAM, VideoModeDescription -AutoSize |
            Out-FormatData |
            Add-FormatData

        # Let's see the difference
        Get-WmiObject Win32_VideoController

        # A better approach might be to use columns of a fixed width.  Let's try this:
        Write-FormatView -TypeName $typeName -Property Name, AdapterRAM, VideoModeDescription -Width 30,15,40 |
            Out-FormatData |
            Add-FormatData

        # Let's see the difference
        Get-WmiObject Win32_VideoController

        # That's much easier to read, but we can still do better.  I can't help but notice that
        # AdapterRAM sounds kind of less like what I want to think of the property, which is Memory.

        # Renaming the property is pretty easy a hashtable is used to describe
        # the items that will be renamed.  The key is the new name, and the value is
        # the old name.  The -Property parameter will contain the display names of
        # each of the properties, including the new name
        Write-FormatView -TypeName $typeName -Property Name, Memory, Mode -Width 30,15,40 -RenamedProperty @{
            "Mode" = "VideoModeDescription"
            "Memory" = "AdapterRAM"
        } | 
            Out-FormatData |
            Add-FormatData
            
        # Let's see the difference    
        Get-WmiObject Win32_VideoController

        # One of the really nifty things about PowerShell is the fact that you can represent disk space
        # and memory in familiar terms, like mb, kb, gb.  Since WMI returns this information to us in 
        # the less readable (but more precise) form of bytes, let's see how we can use the -VirtualProperty
        # parameter of Write-FormatView to show the memory in megabytes

        # -VirtualProperty is a hashtable like -RenamedProperty.  
        # The key in -VirtualProperty is the display name of the property, and
        # the value has to be a PowerShell script block { }
        # This Script Block is pretty simple, it just takes the current value ($_), divides it by megabytes,
        # and then adds the text 'mb' to the end.
        Write-FormatView -TypeName $typeName -Property Name, Memory, Mode -Width 30,15,40 -VirtualProperty @{
            "Memory" = {
                "$($_.AdapterRAM / 1mb) mb"
            }
        } -RenamedProperty @{
            "Mode" = "VideoModeDescription"
        }| 
            Out-FormatData |
            Add-FormatData
            
        # Let's see the difference
        Get-WmiObject Win32_VideoController
    .Example

        # The next view we can improve with Write-FormatView is how devices look
        # A way to get the devices on the operating system is:
        
        Get-WmiObject Win32_PnPEntity
               
        # In earlier examples, we saw how to create a quick table view.  Let's do that for
        # Win32_PnpEntity.
        
        # To start out with, let's get the typename.
        $typeName = 
            Get-WmiObject Win32_PnPEntity | 
                Get-Member |
                Select-Object TypeName -Unique
                
        $typeName |
            Write-FormatView -Property Name, Status, Manufacturer, DeviceID -AutoSize |
            Out-FormatData |
            Add-FormatData            

        # Let's see the difference
        Get-WmiObject Win32_PnpEntity
        
        # That's much better, but the Manufacturer information is repeated a lot, and it
        # takes up a lot of space on the screen.  If we're careful about the order the data
        # goes in, we can improve the appearance of the output by using the -GroupByProperty parameter.
        
        $typeName |
            Write-FormatView -Property Name, Status, DeviceID -AutoSize -GroupByProperty Manufacturer |
            Out-FormatData |
            Add-FormatData            
        
        
        # Let's see the difference
        Get-WmiObject Win32_PnpEntity |
            Sort-Object Manufacturer
        
        # It's very important to sort before you pipe into grouped views.        
        # GroupBy will add a header to all items from the object pipeline that have the same property.
        # Whenever a new value for that property is encountered, a new header will be added.  This means
        # that if you output a bunch of objects by a grouping that comes out of order, you will see
        # a lot of groups.  Let's the difference by showing the same data without sorting.        
        Get-WmiObject Win32_PnpEntity
                                        
        # It looks much, much better sorted
        Get-WmiObject Win32_PnpEntity |
            Sort-Object Manufacturer
            
        # The only unfortunate thing about this view is that both the deviceID and the name are
        # very long.  It would be better to show them in a list instead.  Luckily, Write-FormatView
        # has the -AsList switch, which does just that.        
        $typeName |
            Write-FormatView -Property Name, Status, DeviceID -GroupByProperty Manufacturer -AsList |
            Out-FormatData |
            Add-FormatData            
                                        
        # Let's see the difference
        Get-WmiObject Win32_PnpEntity |
            Sort-Object Manufacturer
    .Example                                                                                                                                    
        # Another view we can improve is the way that XML is rendered in PowerShell
        [xml]"<a an='anattribute'><b d='attribute'><c/></b></a>"        

        # It's not very intuitive.  
        # I cannot really only see the element I am looking at, instead of a chunk of data
        
        # Create a quick view for any XML element.  
        # Piping it into Out-FormatData will make one or more format views into a full format XML file
        # Piping the output of that into Add-FormatData will create a temporary module to hold the formatting data
        # There's also a Remove-FormatData and 
        Write-FormatView -TypeName "System.Xml.XmlNode" -Wrap -Property "Xml" -VirtualProperty @{
            "Xml" = { 
                $strWrite = New-Object IO.StringWriter
                ([xml]$_.Outerxml).Save($strWrite)
                "$strWrite"
            }
        } | 
            Out-FormatData |
            Add-FormatData

        # Now let's take a look at how the xml renders
        [xml]"<a an='anattribute'><b d='attribute'><c /></b></a>"
        
        # In case we want to go back to the original formatter, we can remove the formatter
        # without giving the formatter a name, the 
        Remove-FormatData -Name "System.Xml.XmlNode"

        # And we're back to the original formatting
        [xml]"<a an='anattribute'><b d='attribute'><c/></b></a>"          
    #>
    [CmdletBinding(DefaultParameterSetName="PropertyTable")]
    [OutputType([string])]
    param(    
    # One or more type names.
    #|Default MyCustomTypeName
    [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)]
    [String[]]
    $TypeName,

    # One or more properties to include in the default type view.
    #|Default ACustomProperty
    [Parameter(ParameterSetName='PropertyTable',
        Mandatory=$true,
        Position=1,
        ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='PropertyList',
        Mandatory=$true,
        Position=1,
        ValueFromPipelineByPropertyName=$true)]
    [String[]]$Property,
    
    # If set, will rename the properties in the table.
    # The oldname is the name of the old property, and value is either the new header
    [Parameter(ParameterSetName='PropertyTable', Position=2,ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [string]) {
                throw "All keys and values in the property rename map must be strings" 
            }
        }
        return $true
    })]
    [Hashtable]$RenamedProperty,
    
    # If set, will create a number of virtual properties within a table
    [Parameter(ParameterSetName='PropertyTable', Position=3,ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [ScriptBlock]) {
                throw "The virtual property may only contain property names and the script blocks that will produce the property" 
            }
        }
        return $true    
    })]
    [Hashtable]$VirtualProperty,
    
    # If set, will be used to format the value of a property.
    [Parameter(ParameterSetName='PropertyTable', Position=4,ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [string]) {
                throw "The FormatProperty parameter must contain only strings"
            }
        }
        return $true
    })]
    [Hashtable]$FormatProperty,
    
    
    # If set, then the content will be rendered as a list
    [Parameter(ParameterSetName='PropertyList',
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
    [Switch]$AsList,
            
    # If set, the table will be autosized.
    [Parameter(ParameterSetName='PropertyTable',
        ValueFromPipelineByPropertyName=$true)]
    [Switch]
    $AutoSize,
    
    # The width of any the properties.  This parameter is optional, and cannot be used with
    # AutoSize
    # A negative width is a right justified table.
    # A positive width is a left justified table
    # A width of 0 will be ignored.
    [ValidateRange(-80,80)]
    [Parameter(ParameterSetName='PropertyTable',
        ValueFromPipelineByPropertyName=$true)]
    [Int[]]$Width,    
    

    # The script block used to fill in the contents of a custom control.
    # The script block can either be an arbitrary script, which will be run, or it can include a 
    # number of speicalized commands that will translate into parts of the formatter.
    [Parameter(ParameterSetName='Action',
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
    [ScriptBlock[]]
    $Action,
    
    # The indentation depth of the custom control    
    [Parameter(ParameterSetName='Action',
        ValueFromPipelineByPropertyName=$true)]
    [int]
    $Indent,
    
    # If set, it will treat the type name as a selection set (a set of predefined types)
    [Switch]$IsSelectionSet,
    
    # If wrap is set, then items in the table can span multiple lines
    [Parameter(ParameterSetName='PropertyTable')]
    [Switch]$Wrap,

    # If this is set, then the view will be grouped by a property    
    [String]$GroupByProperty,
    
    # If this is set, then the view will be grouped by the result of a script block
    [ScriptBlock]$GroupByScript,
    
    # If this is set, then the view will be labeled with the value of this parameter.  If
    # this is not present and -GroupView is not present, the result of the script or property name will
    # be used for the label
    [String]$GroupLabel,
    
    # If this is set, then the view will be rendered with a custom action.  The custom action can
    # be defined by using the -AsControl parameter in Write-FormatView.  The action does not have
    # to be defined within the same format file.
    [string]$GroupAction,
    
    # If set, will output the format view as an action (a view that can be reused again and again)
    [Parameter(ParameterSetName='Action',
        ValueFromPipelineByPropertyName=$true)]
    [Switch]$AsControl,
    
    # If the format view is going to be outputted as a control, it will require a name
    [Parameter(ValueFromPipelineByPropertyName=$true)]    
    [String]$Name      
    )
    
    process {
        #region Generate Format Content
        [string]$FormatContent = ""
        if ($psCmdlet.ParameterSetName -eq "Action") {
            $WriteCustomActionParameters = @{}
            foreach ($parameterName in ((Get-Command Write-CustomAction | Select-Object -First 1)).Parameters.Keys) {
                $variable = Get-Variable -Name $parameterName -ErrorAction SilentlyContinue
                if ($variable -ne $null -and $variable.Value) {
                    $null = $WriteCustomActionParameters.Add($parameterName, $variable.Value)
                }
            }
            $FormatContent = Write-CustomAction @WriteCustomActionParameters        
        } elseif ($psCmdlet.ParameterSetName -eq "PropertyTable") {            
            $WriteFormatTableViewParameters = @{}
            foreach ($parameterName in ((Get-Command Write-FormatTableView | Select-Object -First 1)).Parameters.Keys) {
                $variable = Get-Variable -Name $parameterName -ErrorAction SilentlyContinue
                if ($variable -ne $null -and $variable.Value) {
                    $null = $WriteFormatTableViewParameters.Add($parameterName, $variable.Value)
                }
            }
            $formatContent  = Write-FormatTableView @WriteFormatTableViewParameters
        } elseif ($psCmdlet.ParameterSetName -eq "PropertyList") {

            $header = "
<ListControl>
    <ListEntries>
        <ListEntry>
        <ListItems>"
           $middle = foreach ($p in $property){
                "<ListItem><PropertyName>$p</PropertyName></ListItem>"
           }
            $footer = "
        </ListItems>
        </ListEntry>
    </ListEntries>
</ListControl>
"                    
            $FormatContent = $header + $middle + $footer
        
        }
        #endregion Generate Format Content

        if (-not $IsSelectionSet) {
            $typeNameElements = foreach ($t in $typeName) {
                "<TypeName>$T</TypeName>"
            }          
        } else {
            $typeNameElements = foreach ($t in $typeName) {
                "<SelectionSet>$T</SelectionSet>"
            }          

        }
        
        
        if ($AsControl) {            
            if (-not $Name) {
                Write-Error "Controls must have a name"
                return
            }
            $xml = [xml]$formatContent
        } else {
            $ofs = ""   
            $groupBy = ""
            $groupByPropertyOrScript = ""
            $groupLabelOrControl = ""
            if ($GroupByProperty -or $GroupByScript) {
                if ($GroupByProperty) {
                    $groupByPropertyOrScript = "<PropertyName>$GroupByProperty</PropertyName>"
                } else {
                    $groupByPropertyOrScript = "<ScriptBlock>$ScriptBlock</ScriptBlock>"
                }
                if ($GroupLabel) {
                    $GroupByLabelOrControl = "<Label>$GroupLabel</Label>"
                } elseif ($GroupAction) {
                    $GroupByLabelOrControl = "<CustomControlName>$GroupAction</CustomControlName>"
                }
                
                $groupBy  = "<GroupBy>
            $GroupByPropertyOrScript
            $GroupByLabelOrControl
    </GroupBy>"
            }
    $viewName = $Name
    if (-not $viewName)  { 
        $viewName = $typeName
    }
    $xml = [xml]"
    <View>
        <Name>$viewName</Name>
        <ViewSelectedBy>
            $typeNameElements
        </ViewSelectedBy>                    
        $GroupBy
        $FormatContent
    </View>
    "        
        }
        
            $strWrite = New-Object IO.StringWriter
            $xml.Save($strWrite)
            return "$strWrite"

    }

}