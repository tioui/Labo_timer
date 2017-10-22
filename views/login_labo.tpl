{include file="header.tpl"}{assign name="title" value="Connexion" /}{/include}
		<div class="container">
			<center>
				<H1>Vous devez être connecté pour accéder à ce site.</H1>

				{if condition="$has_error"}
					<div name="error" class="alert-danger" role="alert">
						Nom d'usager ou mot de passe incorect
					</div>
				{/if}
				<form method="post" action="{$script_url/}/log/labo/{$laboratory.id/}">
					<table class="form-table">
						<tr>
							<td>Nom d'usager:</td><td><input tabindex=1 type="text" size="12" name="user_name"></td>
							<td rowspan=2 class="form-button"><input tabindex=3 class="btn btn-lg btn-default" type="submit" name="submit" value="Connecter"/></td>
						</tr>
						<tr>
							<td>Mot de passe du laboratoire:</td><td><input tabindex=2 type="password" size="12" name="password"></td>
						</tr>
					</table>
				</form>
			</center>
		<div>
{include file="footer.tpl"/}
