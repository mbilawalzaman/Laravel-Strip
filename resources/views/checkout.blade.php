<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="csrf-token" content="{{ csrf_token() }}">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Stripe Demo</title>
  <style>
    body { font-family: ui-sans-serif, system-ui; max-width: 560px; margin: 40px auto; }
    #msg { margin-top: 10px; }
    button { padding: 10px 16px; }
  </style>
</head>
<body>
  <h1>Pay $10.00</h1>
  <div id="payment-element"></div>
  <button id="pay">Pay</button>
  <div id="msg"></div>

    <script src="https://js.stripe.com/v3"></script>
    <script>
    const stripe = Stripe(@json(config('services.stripe.key')));
    let elements, paymentElement, clientSecret;

    (async () => {
        const res = await fetch(@json(route('stripe.createIntent')), {
        method: 'POST',
        headers: { 
            'Content-Type': 'application/json', 
            'X-CSRF-TOKEN': document.querySelector('meta[name=csrf-token]').content 
        },
        body: JSON.stringify({ amount: 1000, currency: 'usd' })
        });

        const data = await res.json();
        clientSecret = data.clientSecret;

        elements = stripe.elements({ clientSecret });
        paymentElement = elements.create('payment');
        paymentElement.mount('#payment-element');
    })();

    document.getElementById('pay').addEventListener('click', async () => {
        document.getElementById('msg').textContent = 'Processing…';

        const { error } = await stripe.confirmPayment({
        elements,
        confirmParams: {},
        redirect: 'if_required' // stay on page without redirect
        });

        if (error) {
        document.getElementById('msg').textContent = error.message;
        document.getElementById('msg').style.color = 'red';
        } else {
        document.getElementById('msg').textContent = '💰 Payment Successful!';
        document.getElementById('msg').style.color = 'green';

        // Clear and reset the payment fields
        paymentElement.unmount();
        paymentElement.mount('#payment-element');
        }
    });
    </script>


</body>
</html>
