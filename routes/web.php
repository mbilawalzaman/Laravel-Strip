<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PaymentController;


Route::get('/', [PaymentController::class, 'checkout']);
Route::post('/create-payment-intent', [PaymentController::class, 'createPaymentIntent'])
  ->name('stripe.createIntent');
// Route::post('/stripe/webhook', [PaymentController::class, 'webhook'])
//     ->name('stripe.webhook');