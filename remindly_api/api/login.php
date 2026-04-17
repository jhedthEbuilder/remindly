<?php
// remindly_api/api/login.php

require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, 'Only POST requests are allowed', null, 405);
}

// Get and sanitize input
$username = sanitizeInput($_POST['username'] ?? '');
$password = $_POST['password'] ?? '';

// Validation
if (empty($username)) {
    sendResponse(false, 'Username is required', null, 400);
}

if (empty($password)) {
    sendResponse(false, 'Password is required', null, 400);
}

// Check if user exists
$stmt = $conn->prepare("SELECT id, name, username, email, password, is_verified FROM users WHERE username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    sendResponse(false, 'Invalid username or password', null, 401);
}

$user = $result->fetch_assoc();
$stmt->close();

// Verify password
if (!verifyPassword($password, $user['password'])) {
    sendResponse(false, 'Invalid username or password', null, 401);
}

// Check if email is verified
if ($user['is_verified'] == 0) {
    sendResponse(false, 'Please verify your email before logging in', null, 403);
}

// Record login in history
$ipAddress = $_SERVER['REMOTE_ADDR'] ?? '';
$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
$logHistory = $conn->prepare("INSERT INTO login_history (user_id, ip_address, user_agent) VALUES (?, ?, ?)");
$logHistory->bind_param("iss", $user['id'], $ipAddress, $userAgent);
$logHistory->execute();
$logHistory->close();

// Return user data
sendResponse(true, 'Login successful', [
    'user_id' => $user['id'],
    'name' => $user['name'],
    'username' => $user['username'],
    'email' => $user['email']
], 200);

$conn->close();
?>