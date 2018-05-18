<?php
    /* * * * * * * * * * * * * * * * * * * * * *
    *
    *  QD File Listing
    *   -Special Files
    *   --metadata.info
    *   ---[Metadata]
    *   ----title="Title Tag Contents"
    *   ----headgin="H2 Tag Contents"
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
    $title=isset($metadata['Metadata']['title']) ? $metadata['Metadata']['title'] : "File Listing";
    $heading=isset($metadata['Metadata']['heading']) ? $metadata['Metadata']['heading'] : "File Listing";

    $dir=array_values(array_diff(preg_grep('/^\.+.?+/',scandir('.'),PREG_GREP_INVERT),[basename($_SERVER['PHP_SELF']),'metadata.info']));
    if (count($dir)>=1){
        $output.=$indent("<ul>\n",0);
        foreach ($dir as $val){
            $output.=$indent("<li><a href=\"./${val}\">",3);
            $output.=(isset($metadata['Files'][$val]) ? $metadata['Files'][$val] : ${val});
            $output.="</a></li>\n";
        }
        $output.=$indent("</ul>\n",2);
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
        <?=$output;?>
    </div>
</body>
</html>
