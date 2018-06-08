<?php
    // * * * * * * * * * * * * * * * * * * * * *
    //
    // QD File Listing
    //  -Special Files
    //  --metadata.info
    //  ---[Metadata]
    //  ----title="Title Tag Contents"
    //  ----heading="H2 Tag Contents"
    //  ---[Files]
    //  ----filename="Listing Name Override"
    //
    // * * * * * * * * * * * * * * * * * * * * *

    // * * * * * * * * * * * * * * * * * * * * *
    //
    // Config Options
    //
    // Include Directories In Listing?
       $conf['dirs']=TRUE;    
    //
    //* * * * * * * * * * * * * * * * * * * * * * 


    $indent=function($t="",$n=1,$ts="    "){
        return str_repeat($ts,$n).$t;
    };
    $metadata=[];
    if (file_exists("./metadata.info")){
        $metadata = parse_ini_file("./metadata.info",true);
    }
    $output="";    
    $filelist=[];
    $title=isset($metadata['Metadata']['title']) ? $metadata['Metadata']['title'] : "File Listing";
    $heading=isset($metadata['Metadata']['heading']) ? $metadata['Metadata']['heading'] : "File Listing";

    // ^\.+.?+ = match files that start with .
    // PREG_GREP_INVERT = and give me everything that doesn't match
    $predir=preg_grep('/^\.+.?+/',scandir('.'),PREG_GREP_INVERT);

    // Remove this script (with any name) and any file named 'metadata.info' from the listing
    $predir=array_diff($predir,[basename($_SERVER['PHP_SELF']),'metadata.info']);
   

    //Break apart into separate file and directory arrays 
    $dir_d = [];
    $dir_f = [];
    foreach($predir as $val){
        if (is_file($val)){
            $dir_f[] = $val;
        }
        else{
            $dir_d[] = $val;
        }
    }

    //Assemble final array based on directory setting
    if($conf['dirs']){
        $dir = array_merge($dir_d,$dir_f);
    }
    else{
        $dir = array_values($dir_f);
    }
 
    // Reindex the array. Not strictly needed, but meh.
    //$dir=array_values($dir);

    $filelist=[];
    if (count($dir)>=1){
        foreach ($dir as $val){
            $filelist[$val] = isset($metadata['Files'][$val]) ? $metadata['Files'][$val] : $val;
        }
    }
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <title><?=$title;?></title>
</head>
<body>
    <div class="wrapper">
        <h2><?=$heading;?></h2>
        <ul>
<?php
    foreach ($filelist as $key=>$val){
        echo $indent("<li><a href=\"${key}\">${val}".(is_dir($val) ? "/" : "")."</a></li>\n",3);
    }
?>
        </ul>
    </div>
</body>
</html>
