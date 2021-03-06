<div class="settings">
	<form role="form" class="sso-eveonline-settings">
		<div class="row">
			<div class="col-sm-2 col-xs-12 content-header">
				Contents
			</div>
			<div class="col-sm-10 col-xs-12">
				<nav class="section-content">
					<ul></ul>
				</nav>
			</div>
		</div>
		<div class="row">
			<div class="col-sm-2 col-xs-12 settings-header">
				Forum Settings
			</div>
			<div class="col-sm-10 col-xs-12">
				<div class="form-group">
					<label for="name">Frontend Name</label>
					<input type="text" id="frontendName" name="frontendName" title="Name" class="form-control" placeholder="Frontend Name">
				</div>

				<div class="form-group">
					<label for="name">Support Message</label>
					<textarea type="text" id="supportMessage" name="supportMessage" title="Name" class="form-control"></textarea>
				</div>
			</div>
		</div>
		<div class="row">
			<div class="col-sm-2 col-xs-12 settings-header">
				OAuth2 Server Settings
			</div>
			<div class="col-sm-10 col-xs-12">
				<div class="form-group">
					<label for="client_id">Client ID</label>
					<input type="text" id="clientId" name="clientId" title="Client ID" class="form-control" placeholder="Client ID">
				</div>
				<div class="form-group">
					<label for="client_secret">Client Secret</label>
					<input type="text" id="clientSecret" name="clientSecret" title="Client Secret" class="form-control" placeholder="Client Secret">
				</div>
			</div>
		</div>
    <div class="row">
      <div class="col-sm-2 col-xs-12 settings-header">
        Account Transfers
      </div>
      <div class="col-sm-10 col-xs-12">
        <div class="form-group">
          <div class="checkbox">
            <label for="allowAccountTransfers" class="mdl-switch mdl-js-switch mdl-js-ripple-effect">
              <input type="checkbox" class="mdl-switch__input" id="allowAccountTransfers" data-field="allowAccountTransfers" name="allowAccountTransfers" />
              <span class="mdl-switch__label">Allow NodeBB forum account ownership to be transferred to another EVE Online Character.</span>
            </label>
            <p>
              If this is enabled, a user that is logged in can transfer the account ownership to another EVE Online SSO character. This can be done by navigating to /login or visiting their profile page and clicking on "Click here to associated with EVE Online". It's possible for users to accidentally transfer ownership to alt accounts if this is enabled.
            </p>
          </div>
        </div>
      </div>
    </div>
		<div class="row">
			<div class="col-sm-2 col-xs-12 settings-header">
				Group Mapping
			</div>
			<div class="col-sm-10 col-xs-12">
				<div class="form-group">
					<div class="checkbox">
						<label for="mapGroups" class="mdl-switch mdl-js-switch mdl-js-ripple-effect">
							<input type="checkbox" class="mdl-switch__input" id="mapGroups" data-field="mapGroups" name="mapGroups" />
							<span class="mdl-switch__label">Map Groups</span>
						</label>
					</div>
				</div>

				<div class="form-group">
					<table class="table table-striped table-hover group-mapping-listing">
						<thead>
							<tr>
								<th>Corporation</th>
								<th>Title</th>
								<th>Group</th>
								<th></th>
							</tr>
						</thead>
						<tbody>
						<!-- BEGIN groupMappings -->
							<tr>
								<td>{groupMappings.corporationName}</td>
								<td>{groupMappings.title}</td>
								<td><a href="/admin/manage/groups/{groupMappings.groupName}" target="_blank">{groupMappings.groupName}</a></td>
								<td>
									<button type="button" class="group-mappings-delete btn btn-danger btn-sm" data-group-mapping-id="{groupMappings.mappingId}"><i class="fa fa-times"></i></button>
								</td>
							</tr>
						<!-- END groupMappings -->
						</tbody>
					</table>

					<button class="btn btn-primary" id="create-group-mapping">Add Mapping</button>
				</div>

			</div>
		</div>
	</form>
</div>

<div class="modal fade" id="create-group-mapping-modal">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title">Add Group Mapping</h4>
			</div>
			<div class="modal-body">
				<div class="alert alert-danger hide" id="create-modal-error"></div>
				<form>
					<div class="form-group">
						<label for="create-group-mapping-corporation-name">Corporation Name</label>
						<input type="text" class="form-control" id="create-group-mapping-corporation-name" placeholder="Corporation Name" />
					</div>
					<div class="form-group">
						<label for="create-group-mapping-title">Title (Optional)</label>
						<input type="text" class="form-control" id="create-group-mapping-title" placeholder="Title" />
					</div>
					<div class="form-group">
						<label for="create-group-mapping-group-name">Group</label>
						<select class="form-control" id="create-group-mapping-group-slug">
							<!-- BEGIN groups -->
							<option value="{groups.slug}">{groups.name}</option>
							<!-- END groups -->
						</select>
					</div>
				</form>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				<button type="button" class="btn btn-primary" id="create-group-mapping-save">Create</button>
			</div>
		</div>
	</div>
</div>

<button id="save" class="floating-button mdl-button mdl-js-button mdl-button--fab mdl-js-ripple-effect mdl-button--colored">
	<i class="material-icons">save</i>
</button>

<script>
	require(['settings', 'admin/settings'], function(Settings, AdminSettings) {
		Settings.load('sso-eveonline', $('.sso-eveonline-settings'), function() {
			updateGroupMappingListVisibility();
		});

		AdminSettings.populateTOC();

		$('#save').on('click', function() {
			Settings.save('sso-eveonline', $('.sso-eveonline-settings'), function() {
				app.alert({
					type: 'success',
					alert_id: 'sso-eveonline-saved',
					title: 'Settings Saved',
					message: 'Please reload your NodeBB to apply these settings',
					clickfn: function() {
						socket.emit('admin.reload');
					}
				});
			});
		});

		$('#create-group-mapping').on('click', function(evt) {
			$('#create-group-mapping-modal').modal('show');

			evt.preventDefault();
		});

		$('.group-mapping-listing').on('click', '.group-mappings-delete', function(evt) {
			socket.emit('admin.plugins.EveOnlineSSO.deleteGroupMapping', $(this).data("groupMappingId"), function(result) {
				app.alertSuccess("Deleted Group Mapping.");

				updateGroupMappingList();
			});
		});

		$('#create-group-mapping-save').on('click', function(evt) {
			var data = {
				corporationName: $('#create-group-mapping-corporation-name').val(),
				title: $('#create-group-mapping-title').val(),
				groupSlug: $('#create-group-mapping-group-slug').val()
			}

			if (data.corporationName == "") {
				app.alertError("Empty Corportation Name!");
				evt.preventDefault();
				return false;
			}

			socket.emit('admin.plugins.EveOnlineSSO.createGroupMapping', data, function(err, result) {
				if (err) {
					console.log("Error on creating Group:");
					console.log(err);

					app.alertError("Error occured. See console.");
				} else {
					$('#create-group-mapping-modal').modal('hide');
					$('#create-group-mapping-corporation-name').val('')
					$('#create-group-mapping-title').val('')

					app.alertSuccess("Created Group Mapping");
					updateGroupMappingList();
				}
			});

			evt.preventDefault();
			return false;
		});
	});

	function updateGroupMappingList() {
		socket.emit('admin.plugins.EveOnlineSSO.getAllGroupMappings', null, function(err, results) {
			if (err || !results) {
				return app.alertError("Error occured! " + err?err:"");
			}
			
			$('.group-mapping-listing tbody').empty();

			results.forEach(function(item) {
				$('.group-mapping-listing tbody').append('<tr><td>' + item.corporationName + '</td><td>' + item.title + '</td><td>' + item.groupName + '</td><td><button type="button" class="group-mappings-delete btn btn-danger btn-sm" data-group-mapping-id="' + item.mappingId + '"><i class="fa fa-times"></i></button></td></tr>');
			});

			updateGroupMappingListVisibility();
		});
	}

	function updateGroupMappingListVisibility() {
		if ($('.group-mapping-listing tbody tr').length) {
			$('.group-mapping-listing').show()
		} else {
			$('.group-mapping-listing').hide()
		}
	}
</script>