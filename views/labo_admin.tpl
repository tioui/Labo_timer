{include file="header.tpl"}{assign name="title" value="Administration d'un laboratoire." /}{/include}
{include file="menu.tpl"/}
	<div class="container">
		<div class="content_with_menu">
			<H1>Laboratoire {$laboratory.name/}</H1>
			<p>Lien pour participer: <a href="{$participations_link/}">{$participations_link/}</a>
			<div id="table_interventions">
{$table_interventions/}
			</div>
		</div>
	</div>
<script type="text/javascript" src="{$script_url/}/www/scripts/hand_raise.js"></script>
<script>
setInterval(update_interventions, 5000, "{$script_url/}/labo/{$laboratory.id/}/admin/update_interventions")
</script>

{include file="footer.tpl"/}
