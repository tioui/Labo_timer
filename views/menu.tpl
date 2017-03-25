<div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
  <div class="container">
	<div class="collapse navbar-collapse">
	  <ul class="nav navbar-nav">
		<li{if condition="$is_list_laboratories"} class="active"{/if}><a href="{$script_url/}/laboratories/list/">Laboratoires</a></li>
		<li{if condition="$is_list_administrators"} class="active"{/if}><a href="{$script_url/}/administrators/list/">Administrateurs</a></li>
		<li{if condition="$is_list_users"} class="active"{/if}><a href="{$script_url/}/users/list/">Utilisateurs</a></li>
		<li><a href="{$script_url/}/log/out/">Déconnexion</a></li>
	  </ul>
	</div><!--/.nav-collapse -->
  </div>
</div>
