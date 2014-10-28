<?php

//Slim Routing Patch (http://www.johncongdon.com/page/5/)
$_SERVER['SCRIPT_NAME'] = '/index.php';

//Composer autoloading
require '../vendor/autoload.php';
require '../app/models/Geoname.php';

//Bootstrap database ORM
require '../app/Database.php';


$app = new \Slim\Slim();

//Use JSON responses for API
if (stripos($_SERVER['REQUEST_URI'], 'api') !== false){
    $app->response->headers->set('Content-Type', 'application/json');
}

//Set up the basic primary id record lookup API route.
$app->get('/api/primary/:geonameid', function ($geonameid) {
    
    $geoname = Geoname::find($geonameid);
    
    echo $geoname->toJson();
    
});

$app->get('/api/geoname/:country/:admin1/:name', function ($country, $admin1, $name) {
    
    $geonames = Geoname::where('name', 'LIKE', '%'.$name.'%')
        ->where('admin1', '=', $admin1)
        ->where('country', '=', $country)
        ->get();
    
    echo $geonames->toJson();
    
});

$app->get('/', function () {
    echo "<h1>Welcome to GeoSlim!</h1>";
    echo '<p>GeoSlim is a Slim PHP framework API wrapper around the <a href="http://www.geonames.org/">GeoNames</a> locations database.</p>';
    echo '<p>The Eloquent ORM system is used to make database interaction easy.</p>';
    echo '<p><a href="http://geoslim.local/api/primary/4526992">Primary lookup request</a></p>';
    echo '<p><a href="http://geoslim.local/api/geoname/US/OH/upper+arlington">Search request</a></p>';
    echo '<p>For benchmarking information visit <a href="http://reidmayo.com/2014/10/25/benchmarking-phalcon-php-vs-slim-framework-with-opcache-vs-node-js/">Reidmayo.com</a>.</p>';
});



$app->run();
