	<div style="text-align:center; margin:100px;">
		<form method="post" action="">
			<table border="0">
				<? if($parse_url = parse_url(get($_SERVER, 'HTTP_REFERER'))): ?>
					<input type="hidden" name="HTTP_REFERER" value="<?=$parse_url['path']?>">
				<? endif; ?>
				<input type="hidden" value="Аутентификация" name="reg">
				<!-- <tr><td>OpenID: </td><td><img src="http://wiki.openid.net/f/openid-16x16.gif"> <a href="/users:openid">Представиться</a></td></tr> -->
				<tbody>
					<tr>
						<td>Вы вошли как: </td>
						<td><input type="text" style="width:100%;" disabled value="<?=$conf['user']['uname']?>"></td>
					</tr>
					<tr>
						<td>Логин: </td>
						<td><input type="text" style="width:100%;" name="name"></td>
					</tr>
					<tr>
						<td>Пароль: </td>
						<td><input type="password" style="width:100%;" name="pass"></td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<td><span style="float:right;">
							<input type="submit" value="Войти"></span>
							<a href="/users:resque">Восстановление</a><br /><a href="/users:reg">Регистрация</a>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
