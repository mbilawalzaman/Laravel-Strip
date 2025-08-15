<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PaymentController;
use Illuminate\Support\Facades\Log;

Route::post('/stripe/webhook', [PaymentController::class, 'webhook'])
    ->name('stripe.webhook');
    
Log::info('Stripe webhook route registered:', [
    'uri' => '/api/stripe/webhook',
    'name' => 'stripe.webhook',
    'action' => PaymentController::class . '@webhook',
]);
