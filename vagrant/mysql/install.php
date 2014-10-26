<?php
/**
 * This creates the geophalcon user and related database
 */

$db = new PDO('mysql:host=127.0.0.1;', 'root', 'root');

//Create user
$query = $db->prepare("CREATE USER 'geoname'@'geoname' IDENTIFIED BY 'geoname'");
$result = $query->execute();

//Give all permissions
$query = $db->prepare("GRANT ALL PRIVILEGES ON * . * TO 'geoname'@'geoname'");
$result = $query->execute();


//Create DB
$query = $db->prepare("CREATE DATABASE geoname");
$result = $query->execute();
