<? # Заголовка блока
################################# php код #################################

//if(array_key_exists('blocks', $_GET['m']) && array_key_exists('null', $_GET) && ($_GET['id'] == $arg['blocknum']) && $_POST){ exit(mpre($_POST)) };

################################# верстка ################################# ?>
<div class="block_<?=$arg['blocknum']?>">
	<?=$arg['modname']?>_<?=$arg['fn']?>
	block_<?=$arg['blocknum']?>
</div>
