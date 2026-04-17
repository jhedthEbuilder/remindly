<?php
// remindly_api/api/check_username.php

require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, 'Only POST requests are allowed', null, 405);
}

$username = sanitizeInput($_POST['username'] ?? '');

if (empty($username)) {
    sendResponse(false, 'Username is required', null, 400);
}

if (strlen($username) < 3) {
    sendResponse(false, 'Username must be at least 3 characters', null, 400);
}

$stmt = $conn->prepare("SELECT id FROM users WHERE username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

$available = $result->num_rows === 0;

sendResponse(true, $available ? 'Username available' : 'Username already taken', [
    'available' => $available
], 200);

$stmt->close();
$conn->close();
?>