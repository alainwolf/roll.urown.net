#!/usr/bin/php
<?php

require '/usr/local/libcsp-builder/vendor/autoload.php';

use \ParagonIE\CSPBuilder\CSPBuilder;

//$policy = CSPBuilder::fromFile('./my_csp.json');
$policy = CSPBuilder::fromFile("$argv[1].json");
$policy->saveSnippet(
    "$argv[1].conf",
    CSPBuilder::FORMAT_NGINX
);
