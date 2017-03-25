{include file="views/header.tpl"}
	{assign name="title" value="Suppression d'un laboratoire" /}
{/include}
{include file="views/menu.tpl"}{/include}
	<div class="container">
		<div class="content_with_menu">
			<H1>Suppression d'un laboratoire</H1>
			<form method="post"  id="remove_form" action="{$script_url/}/laboratories/remove/{$laboratory.id/}">
				<p>Voulez-vous réellement effacer le laboratoire suivant:
				<input type="hidden" name="id" value="{$laboratory.id/}">
				<table class="form-table">
					<tr>
						<td>
							Nom du laboratoire:
						</td>
						<td>
							{$laboratory.name/}
						</td>
					</tr>
					<tr>
						<td>
							Mot de passe:
						</td>
						<td>
							{$laboratory.password/}
						</td>
					</tr>
					<tr>
						<td>
							Date
						</td>
						<td>
							{$laboratory.date/}
						</td>
					</tr>
					<tr>
						<td>
							Heure de début
						</td>
						<td>
							{$laboratory.start_time/}
						</td>
					</tr>
					<tr>
						<td>
							Heure de fin
						</td>
						<td>
							{$laboratory.end_time/}
						</td>
					</tr>
				</table>
				<input type="submit" class="btn btn-lg btn-default" name="apply" value="Détruire">
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
{include file="views/footer.tpl"/}
