<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Stripe\StripeClient;
use Stripe\Webhook;


class PaymentController extends Controller
{
    public function checkout()
    {
        return view('checkout');
    }

    public function createPaymentIntent(Request $request)
    {
        $amount   = (int) ($request->input('amount', 1000)); // cents
        $currency = $request->input('currency', 'usd');

        $stripe = new StripeClient(config('services.stripe.secret'));

        $pi = $stripe->paymentIntents->create([
            'amount'   => $amount,
            'currency' => $currency,
            'automatic_payment_methods' => ['enabled' => true],
        ]);

        return response()->json(['clientSecret' => $pi->client_secret]);
    }

    public function webhook(Request $request)
    {
        $sigHeader = $request->header('Stripe-Signature');
        $secret = config('services.stripe_webhook.secret');

        try {
            $event = Webhook::constructEvent(
                $request->getContent(),
                $sigHeader,
                $secret
            );
        } catch (\UnexpectedValueException $e) {
            // Invalid payload
            return response('Invalid payload', 400);
        } catch (\Stripe\Exception\SignatureVerificationException $e) {
            // Invalid signature
            return response('Invalid signature', 400);
        }

        // Save event to DB
        DB::table('stripe_events')->updateOrInsert(
            ['event_id' => $event->id],
            [
                'type' => $event->type,
                'payload' => json_encode($event),
                'updated_at' => now(),
                'created_at' => now(),
            ]
        );

        // Handle specific event types
        if ($event->type === 'payment_intent.succeeded') {
            $intent = $event->data->object;
            Log::info('💰 Payment succeeded', ['id' => $intent->id]);
        }

        return response()->json(['status' => 'success']);
    }

}


