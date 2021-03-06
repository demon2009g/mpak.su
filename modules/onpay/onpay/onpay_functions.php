<?function get_constant($name) {
	global $conf;
	$arr = array(
		     'onpay_login' => $conf['settings']['onpay_onpay_login'],
		     'private_code' => $conf['settings']['onpay_private_code'],
		     'url_success' => 'http://www.domen.com',
		     'use_balance_table' => true,
		     'new_operation_status' => 0
		    );
	return $arr[$name];
}

function get_iframe_url_params($operation_id, $sum, $md5check) {
	return "pay_mode=fix&pay_for=$operation_id&price=$sum&currency=RUR&convert=yes&md5=$md5check&url_success=".get_constant('url_success');
}

function data_create_operation($sum) {
/*  $userid 			= 1;
  $type 				= "Р’РЅРµС€РЅСЏСЏ";
  $comment 			= "РџРѕРїРѕР»РЅРµРЅРёРµ СЃС‡РµС‚Р°";
  $description 	= "С‡РµСЂРµР· СЃРёСЃС‚РµРјСѓ Onpay";*/

	$query = "INSERT INTO `mp_onpay_operations` (`sum`,`uid`, `status`, `type`, `comment`, `description`, `date`) VALUES('". (int)$sum. "', '". (int)$userid. "', ".get_constant('new_operation_status').", '". mpquot($type). "', '". mpquot($comment). "', '". mpquot($description). "', NOW());"; 
  return mysql_query($query);
}

function data_get_created_operation($id) {
	$query = "SELECT * FROM mp_onpay_operations WHERE `id`='". (int)$id. "' and `status`=".get_constant('new_operation_status');
  return mysql_query($query); 
}

function data_set_operation_processed($id) {
	
	$query = "UPDATE mp_onpay_operations SET status=1, date=NOW() WHERE id='". (int)$id. "'";
	return mysql_query($query); 
}

function data_update_user_balance($operation_id, $sum) {
	global $conf;
	$operation = data_get_created_operation($operation_id);
	if (mysql_num_rows($operation) == 1) {
		$operation_row = mysql_fetch_assoc($operation);
		$userid = $operation_row["uid"];
		
		$query = "INSERT INTO mp_onpay_balances SET uid=". (int)$userid. ", sum=". (int)$sum. ", date=NOW() ON DUPLICATE KEY UPDATE sum=sum+". (int)$sum. ", date=NOW()";

		mpevent("Новый платеж", $operation_id, $operation_row['uid'], $operation_row);
		return mysql_query($query);
	} else {
		return false;
	}
}
function to_float($sum) { 
  if (strpos($sum, ".")) {
		$sum = round($sum, 2);
	} else {
		$sum = $sum.".0";
	} 
  return $sum; 
}

function answer($type, $code, $pay_for, $order_amount, $order_currency, $text) { 
  $md5 = strtoupper(md5("$type;$pay_for;$order_amount;$order_currency;$code;".get_constant('private_code'))); 
  return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<result>\n<code>$code</code>\n<pay_for>$pay_for</pay_for>\n<comment>$text</comment>\n<md5>$md5</md5>\n</result>";
} 

function answerpay($type, $code, $pay_for, $order_amount, $order_currency, $text, $onpay_id) { 
  $md5 = strtoupper(md5("$type;$pay_for;$onpay_id;$pay_for;$order_amount;$order_currency;$code;".get_constant('private_code'))); 
  return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<result>\n<code>$code</code>\n<comment>$text</comment>\n<onpay_id>$onpay_id</onpay_id>\n<pay_for>$pay_for</pay_for>\n<order_id>$pay_for</order_id>\n<md5>$md5</md5>\n</result>"; 
}

function process_first_step() {
	$sum = $_REQUEST['sum'];
	$output = '';
	$err = '';
	
	if (is_numeric($sum)){
			$result = data_create_operation($sum);
	} else {
    $err = 'Р’ РїРѕР»Рµ СЃСѓРјРјР° РЅРµ С‡РёСЃР»РѕРІРѕРµ Р·РЅР°С‡РµРЅРёРµ';
	}
	if ($result) { 
	    $number = mysql_insert_id();
	    $sumformd5 = to_float($sum);
	    $md5check = md5("fix;$sumformd5;RUR;$number;yes;".get_constant('private_code')); 
	    $url = "http://secure.onpay.ru/pay/".get_constant('onpay_login')."?".get_iframe_url_params($number, $sum, $md5check);
			$output = '<iframe src="'.$url.'" width="300" height="500" frameborder=no scrolling=no></iframe> 
	    					 <form method=post action="'.$_SERVER['HTTP_REFERER'].'"><input type="submit" value="Р’РµСЂРЅСѓС‚СЊСЃСЏ"></form>';
	} else {
	  $err = empty($err) ? mysql_error() : $err;
		$output = "onpay script: РћС€РёР±РєР° СЃРѕС…СЂР°РЅРµРЅРёСЏ РґР°РЅРЅС‹С…. (" . $err . ")";
	}
	return $output;
}

function process_api_request() {
	$rezult = ''; 
	$error = ''; 
	if ($_REQUEST['type'] == 'check') { 
	    $order_amount 	= $_REQUEST['order_amount']; 
	    $order_currency = $_REQUEST['order_currency']; 
	    $pay_for 				= $_REQUEST['pay_for']; 
	    $md5 						= $_REQUEST['md5']; 
	    $rezult = answer($_REQUEST['type'],0, $pay_for, $order_amount, $order_currency, 'OK'); 
	} 

	if ($_REQUEST['type'] == 'pay') { 
	    $onpay_id 					= $_REQUEST['onpay_id']; 
	    $pay_for 						= $_REQUEST['pay_for']; 
	    $order_amount 			= $_REQUEST['order_amount']; 
	    $order_currency			= $_REQUEST['order_currency']; 
	    $balance_amount 		= $_REQUEST['balance_amount']; 
	    $balance_currency 	= $_REQUEST['balance_currency']; 
	    $exchange_rate 			= $_REQUEST['exchange_rate']; 
	    $paymentDateTime 		= $_REQUEST['paymentDateTime']; 
	    $md5 								= $_REQUEST['md5']; 
	
	    if (empty($onpay_id)) {$error .="РќРµ СѓРєР°Р·Р°РЅ id<br>";} 
	    else {if (!is_numeric(intval($onpay_id))) {$error .="РџР°СЂР°РјРµС‚СЂ РЅРµ СЏРІР»СЏРµС‚СЃСЏ С‡РёСЃР»РѕРј<br>";}} 
	    if (empty($order_amount)) {$error .="РќРµ СѓРєР°Р·Р°РЅР° СЃСѓРјРјР°<br>";} 
	    else {if (!is_numeric($order_amount)) {$error .="РџР°СЂР°РјРµС‚СЂ РЅРµ СЏРІР»СЏРµС‚СЃСЏ С‡РёСЃР»РѕРј<br>";}} 
	    if (empty($balance_amount)) {$error .="РќРµ СѓРєР°Р·Р°РЅР° СЃСѓРјРјР°<br>";} 
	    else {if (!is_numeric(intval($balance_amount))) {$error .="РџР°СЂР°РјРµС‚СЂ РЅРµ СЏРІР»СЏРµС‚СЃСЏ С‡РёСЃР»РѕРј<br>";}} 
	    if (empty($balance_currency)) {$error .="РќРµ СѓРєР°Р·Р°РЅР° РІР°Р»СЋС‚Р°<br>";} 
	    else {if (strlen($balance_currency)>4) {$error .="РџР°СЂР°РјРµС‚СЂ СЃР»РёС€РєРѕРј РґР»РёРЅРЅС‹Р№<br>";}} 
	    if (empty($order_currency)) {$error .="РќРµ СѓРєР°Р·Р°РЅР° РІР°Р»СЋС‚Р°<br>";} 
	    else {if (strlen($order_currency)>4) {$error .="РџР°СЂР°РјРµС‚СЂ СЃР»РёС€РєРѕРј РґР»РёРЅРЅС‹Р№<br>";}} 
	    if (empty($exchange_rate)) {$error .="РќРµ СѓРєР°Р·Р°РЅР° СЃСѓРјРјР°<br>";} 
	    else {if (!is_numeric($exchange_rate)) {$error .="РџР°СЂР°РјРµС‚СЂ РЅРµ СЏРІР»СЏРµС‚СЃСЏ С‡РёСЃР»РѕРј<br>";}} 
			if (!$error) { 
				if (is_numeric($pay_for)) {
					$sum = floatval($order_amount); 
					$rezult = data_get_created_operation($pay_for);
					if (mysql_num_rows($rezult) == 1) { 
						$md5fb = strtoupper(md5($_REQUEST['type'].";".$pay_for.";".$onpay_id.";".$order_amount.";".$order_currency.";".get_constant('private_code'))); 
						if ($md5fb != $md5) {
							$rezult = answerpay($_REQUEST['type'], 8, $pay_for, $order_amount, $order_currency, 'Md5 signature is wrong. Expected '.$md5fb, $onpay_id);
						} else { 
							$time = time(); 
							$rezult_balance = get_constant('use_balance_table') ? data_update_user_balance($pay_for, $sum) : true;
							$rezult_operation = data_set_operation_processed($pay_for);
							if ($rezult_operation && $rezult_balance) {
								$rezult = answerpay($_REQUEST['type'], 0, $pay_for, $order_amount, $order_currency, 'OK', $onpay_id);
							} else {
								$rezult = answerpay($_REQUEST['type'], 9, $pay_for, $order_amount, $order_currency, "Error in mechant database queries: operation or balance tables error", $onpay_id);
							} 
						}
					} else {
						$rezult = answerpay($_REQUEST['type'], 10, $pay_for, $order_amount, $order_currency, 'Cannot find any pay rows acording to this parameters: wrong payment', $onpay_id);
					} 
				} else {
					$rezult = answerpay($_REQUEST['type'], 11, $pay_for, $order_amount, $order_currency, 'Error in parameters data', $onpay_id); 
				} 
			} else {
				$rezult = answerpay($_REQUEST['type'], 12, $pay_for, $order_amount, $order_currency, 'Error in parameters data: '.$error, $onpay_id); 
			} 
	} 
	return $rezult;
}
?>
