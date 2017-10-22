{include file="header.tpl"}
	{if condition="$create"}
		{assign name="title" value="Création d'un laboratoire" /}
	{/if}
	{unless condition="$create"}
		{assign name="title" value="Modification d'un laboratoire" /}
	{/unless}
{/include}
{include file="menu.tpl"}{/include}
	<div class="container">
		<div class="content_with_menu">
			{if condition="$create"}
				<H1>Création d'un laboratoire</H1>
			{/if}
			{unless condition="$create"}
				<H1>Modification d'un laboratoire</H1>
			{/unless}

			{if condition="$unknown_error"}
				<div class="alert-danger" role="alert">
					Un erreur non géré est survenue.
				</div>
			{/if}
			{if condition="$date_not_valid"}
				<div class="alert-danger" role="alert">
					La date entrée est invalide. Veuillez respecter le format mm/dd/yyyy.
				</div>
			{/if}
			{if condition="$start_time_not_valid"}
				<div class="alert-danger" role="alert">
					L'heure de début est invalide. Veuillez respecter le format hh:mm.
				</div>
			{/if}
			{if condition="$end_time_not_valid"}
				<div class="alert-danger" role="alert">
					L'heure de fin est invalide. Veuillez respecter le format hh:mm.
				</div>
			{/if}
			{if condition="$password_not_valid"}
				<div class="alert-danger" role="alert">
					Le mot de passe entré est invalide.
				</div>
			{/if}
			{if condition="$name_not_valid"}
				<div class="alert-danger" role="alert">
					Le nom entré est invalide.
				</div>
			{/if}

			<form method="post"  id="edit_form" action="{$script_url/}/laboratories/{if condition="$create"}create{/if}{unless condition="$create"}edit/{$laboratory.id/}{/unless}">
				<input type="hidden" name="id" value="{$laboratory.id/}">
				<table class="form-table">
					<tr>
						<td>
							Nom du laboratoire:
						</td>
						<td>
							<input type="text" name="name" value="{$laboratory.name/}">
						</td>
					</tr>
					<tr>
						<td>
							Mot de passe:
						</td>
						<td>
							<input type="text" name="password" value="{$laboratory.password/}">
						</td>
					</tr>
					<tr>
						<td>
							Date
						</td>
						<td>
							<input type="text" class="date start" name="date" value="{$laboratory.date/}">
						</td>
					</tr>
					<tr>
						<td>
							Heure de début
						</td>
						<td>
							<input type="text" class="time start" name="start_time" value="{$laboratory.start_time/}">
						</td>
					</tr>
					<tr>
						<td>
							Heure de fin
						</td>
						<td>
							<input type="text" class="time end" name="end_time" value="{$laboratory.end_time/}">
						</td>
					</tr>
				</table>
			{if condition="$create"}
				<input type="submit" class="btn btn-lg btn-default" name="apply" value="Créer">
			{/if}
			{unless condition="$create"}
				<input type="submit" class="btn btn-lg btn-default" name="apply" value="Modifier">
			{/unless}
				<input type="reset" class="btn btn-lg btn-default" name="reset" value="Réinitialiser">
				<input type="submit" class="btn btn-lg btn-default" name="cancel" value="Annuler">
			</form>
		</div>
	</div>

		<link rel="stylesheet" type="text/css" href="{$script_url/}/www/css/Timepicker/jquery.timepicker.css" />
		<link rel="stylesheet" type="text/css" href="{$script_url/}/www/css/Timepicker/bootstrap-datepicker.css" />
		<script type="text/javascript" src="{$script_url/}/www/scripts/jquery-3.1.1.min.js"></script>
		<script type="text/javascript" src="{$script_url/}/www/scripts/Timepicker/jquery.timepicker.js"></script>
		<script type="text/javascript" src="{$script_url/}/www/scripts/Timepicker/bootstrap-datepicker.js"></script>

		<script type="text/javascript" src="{$script_url/}/www/scripts/Datepair/datepair.js"></script>
		<script type="text/javascript" src="{$script_url/}/www/scripts/Datepair/jquery.datepair.js"></script>
{literal}
		<script>
		    // initialize input widgets first
		    $('#edit_form .time').timepicker({
		        'showDuration': true,
		        'timeFormat': 'G:i'
		    });
		
		    $('#edit_form .date').datepicker({
		        'format': 'mm/dd/yyyy',
		        'autoclose': true
		    });
		
		    // initialize datepair
		    $('#edit_form').datepair();
		</script>
{/literal}
{include file="footer.tpl"/}
