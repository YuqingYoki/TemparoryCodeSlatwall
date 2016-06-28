// Options (many-to-many - owner)
	public void function addOption(required any option) {
		if(arguments.option.isNew() or !hasOption(arguments.option)) {
			arrayAppend(variables.options, arguments.option);
		}
		if(isNew() or !arguments.option.hasSku( this )) {
			arrayAppend(arguments.option.getSkus(), this);
		}
	}
	public void function removeOption(required any option) {
		var thisIndex = arrayFind(variables.options, arguments.option);
		if(thisIndex > 0) {
			arrayDeleteAt(variables.options, thisIndex);
		}
		var thatIndex = arrayFind(arguments.option.getSkus(), this);
		if(thatIndex > 0) {
			arrayDeleteAt(arguments.option.getSkus(), thatIndex);
		}
	}