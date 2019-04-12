//javascript for node.js server
router.post('/paypal', function (req, res) {
    var transactionErrors;
    var amount = req.body.amount;
    var nonce = req.body.payment_method_nonce;
            
    var saleRequest = {
        amount: req.body.amount,
        paymentMethodNonce: req.body.payment_method_nonce,
        orderId: "Mapped to PayPal Invoice Number",
        options: {
            submitForSettlement: true,
            paypal: {
                customField: "PayPal custom field",
                description: "Description for PayPal email receipt",
            },
        }
    };
            
    gateway.transaction.sale(saleRequest, function (err, result) {
        if (err) {
            res.json({"success": "0", "transaction_error": err});
        } else if (result.success) {
                
            res.json({"success": result.success, "transaction_id": result.transaction.id});
        } else {
            res.json({"success": "0", "transaction_error": result.message});
        }
    });
});
module.exports = router;
