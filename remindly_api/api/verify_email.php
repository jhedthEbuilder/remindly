<?php
// remindly_api/api/verify_email.php

require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, 'Only POST requests are allowed', null, 405);
}

// Get token
$token = sanitizeInput($_POST['token'] ?? '');

if (empty($token)) {
    sendResponse(false, 'Verification token is required', null, 400);
}

// Check if token exists and is not expired
$stmt = $conn->prepare("SELECT user_id, expires_at FROM email_verifications WHERE token = ? AND expires_at > NOW()");
$stmt->bind_param("s", $token);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    sendResponse(false, 'Invalid or expired verification token', null, 400);
}

$verification = $result->fetch_assoc();
$userId = $verification['user_id'];
$stmt->close();

// Update user as verified
$updateUser = $conn->prepare("UPDATE users SET is_verified = 1, verification_token = NULL WHERE id = ?");
$updateUser->bind_param("i", $userId);

if ($updateUser->execute()) {
    // Delete verification record
    $deleteVerification = $conn->prepare("DELETE FROM email_verifications WHERE token = ?");
    $deleteVerification->bind_param("s", $token);
    $deleteVerification->execute();
    $deleteVerification->close();
    
    sendResponse(true, 'Email verified successfully', null, 200);
} else {
    sendResponse(false, 'Verification failed', null, 500);
}

$updateUser->close();
$conn->close();
?>