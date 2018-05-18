<?php
    /* * * * * * * * * * * * * * * * * * * * * *
    *
    *  QD File Listing
    *   -Special Files
    *   --metadata.info
    *   ---[Metadata]
    *   ----title="Title Tag Contents"
    *   ----heading="H2 Tag Contents"
    *   ---[Files]
    *   ----filename="Listing Name Override"
    *
    * * * * * * * * * * * * * * * * * * * * * */

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
    $dir=preg_grep('/^\.+.?+/',scandir('.'),PREG_GREP_INVERT);

    // Remove this script (with any name) and any file named 'metadata.info' from the listing
    $dir=array_diff($dir,[basename($_SERVER['PHP_SELF']),'metadata.info']);
    
    // Reindex the array. Not strictly needed, but meh.
    $dir=array_values($dir);


    if (count($dir)>=1){
//        $output.=$indent("<ul>\n",0);
        foreach ($dir as $val){
//            $output.=$indent("<li><a href=\"./${val}\">",3);
//            $output.=(isset($metadata['Files'][$val]) ? $metadata['Files'][$val] : ${val});
//            $output.="</a></li>\n";
            $filelist[${val}] = isset($metadata['Files'][${val}]) ? $metadata['Files'][${val}] : ${val};
        }
//        $output.=$indent("</ul>\n",2);
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
        echo $indent("<li><a href=\"${val}\">${key}</a></li>\n",3);
    }
?>
        </ul>
    </div>
</body>
</html>
