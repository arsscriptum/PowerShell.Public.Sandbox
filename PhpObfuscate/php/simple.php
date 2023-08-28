<!-- 
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   custom webshell
-->



<?php
    function getHeightCfg(){
        return '200px';
    }
    function getMarginCfg(){
        return '20px';
    }
    function getBorderCfg(){
        return '5px solid';
    }
    function getPrimaryColor(){
        return '#00ff00';
    }
    function getSecondaryColor(){
        return '#d92626';
    }
    function getThirdColor(){
        return '#d0d0d0';
    }
    function getCommandColor(){
        return '#ff0066';
    }
    function getCommandOutputColor(){
        return '#3ADF00';
    }
    function getExplorerColor(){
        return '#3ADF00';
    }
    function getDirectoryColor(){
        return '#3ADF00';
    }
    function getNavTextColor(){
        return '#ff5500';
    }
    function getHeaderTextColor(){
        return '#C0C0C0';
    }
    function getNavTextHoverColor(){
        return '#C0C0C0';
    }
    function getButtonsColor(){
        return '#3ADF00';
    }
    function getBgColor($level){
        switch ($level) {
          case 1:
            return '#ABBAEA';
            break;
          case 2:
            return '#FBD603';
            break;
          case 3:
            return '#FBBABA';
            break;
          case 4:
            return '#FBD603';
            break;
          default:
            return '#ACBAEE';
        }
        return '#404040';
    }
   
?>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>My WebShell</title>
        
              
        <style>
            .pclass-1 {
                    background-color: <?php echo getExplorerColor();?>;
                    color: <?php echo getNavTextColor();?>;
                    font-family: "Lucida Console", "Courier New", monospace;
            }
            .div-1 {
                background-color: <?php echo getBgColor(1);?>;
            }
            .div-2 {
                background-color: <?php echo getBgColor(2);?>;
            }
            
            .div-3 {
                background-color: <?php echo getBgColor(3);?>;
            }
            .child {
                height: <?php echo getHeightCfg();?>;
                margin: <?php echo getMarginCfg();?>;
                border: <?php echo getBorderCfg();?>;
                background-color: <?php echo getBgColor(4);?>;
            }
        </style>
    
    </head>
        <body>
            <div class="div-1">THIS IS A TEST PAGE</div>
            <div class="div-2"> I love OBFUSCATION </div>
            <div class="div-3"> I love PHP </div>
            <p>This is the parent section in the HTML CODE</p>

            <div class="child">
                <p class="pclass-1">This example shows that changing the background color of a div does not affect the border and margin of the div.</p>
            </div>
        </body>
</html>



