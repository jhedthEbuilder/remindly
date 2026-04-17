<?php
// remindly_api/api/register.php

require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, 'Only POST requests are allowed', null, 405);
}

// Get and sanitize input
$name = sanitizeInput($_POST['name'] ?? '');
$username = sanitizeInput($_POST['username'] ?? '');
$email = sanitizeInput($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';
$confirmPassword = $_POST['confirm_password'] ?? '';

// Validation
if (empty($name)) {
    sendResponse(false, 'Name is required', null, 400);
}

if (empty($username)) {
    sendResponse(false, 'Username is required', null, 400);
}

if (strlen($username) < 3) {
    sendResponse(false, 'Username must be at least 3 characters', null, 400);
}

if (empty($email)) {
    sendResponse(false, 'Email is required', null, 400);
}

if (!validateEmail($email)) {
    sendResponse(false, 'Invalid email format', null, 400);
}

if (empty($password)) {
    sendResponse(false, 'Password is required', null, 400);
}

if (!validatePassword($password)) {
    sendResponse(false, 'Password must be at least 6 characters', null, 400);
}

if ($password !== $confirmPassword) {
    sendResponse(false, 'Passwords do not match', null, 400);
}

// Check if username already exists
$checkUsername = $conn->prepare("SELECT id FROM users WHERE username = ?");
$checkUsername->bind_param("s", $username);
$checkUsername->execute();
if ($checkUsername->get_result()->num_rows > 0) {
    sendResponse(false, 'Username already exists', null, 409);
}
$checkUsername->close();

// Check if email already exists
$checkEmail = $conn->prepare("SELECT id FROM users WHERE email = ?");
$checkEmail->bind_param("s", $email);
$checkEmail->execute();
if ($checkEmail->get_result()->num_rows > 0) {
    sendResponse(false, 'Email already registered', null, 409);
}
$checkEmail->close();

// Hash password
$hashedPassword = hashPassword($password);

// Generate verification token
$verificationToken = generateToken();

// Insert user into database
$insertUser = $conn->prepare("INSERT INTO users (name, username, email, password, verification_token) VALUES (?, ?, ?, ?, ?)");
$insertUser->bind_param("sssss", $name, $username, $email, $hashedPassword, $verificationToken);

if ($insertUser->execute()) {
    $userId = $conn->insert_id;
    
    // Insert into email_verifications table
    $expiresAt = date('Y-m-d H:i:s', strtotime('+24 hours'));
    $insertVerification = $conn->prepare("INSERT INTO email_verifications (user_id, token, expires_at) VALUES (?, ?, ?)");
    $insertVerification->bind_param("iss", $userId, $verificationToken, $expiresAt);
    $insertVerification->execute();
    $insertVerification->close();
    
    // Here you would send verification email
    // For now, we'll just return success
    sendResponse(true, 'Account created successfully. Please verify your email.', [
        'user_id' => $userId,
        'username' => $username,
        'email' => $email
    ], 201);
} else {
    sendResponse(false, 'Registration failed: ' . $conn->error, null, 500);
}

$insertUser->close();
$conn->close();
?>