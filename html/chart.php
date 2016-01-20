<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title>Chart Test</title>
</head>
<body>

<h4>Modulus Video Chart:</h4>
<?php
  $mygraph = new chart(300,200);
  $mygraph->plot($data);
  $mygraph->stroke(); 
?>
</body>
</html>
