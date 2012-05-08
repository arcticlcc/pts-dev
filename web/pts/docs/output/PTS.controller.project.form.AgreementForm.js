Ext.data.JsonP.PTS_controller_project_form_AgreementForm({"mixedInto":[],"uses":[],"allMixins":[],"html_meta":{},"extends":"PTS.controller.project.form.BaseModificationForm","statics":{"method":[],"cfg":[],"property":[],"event":[],"css_var":[],"css_mixin":[]},"files":[{"href":"AgreementForm.html#PTS-controller-project-form-AgreementForm","filename":"AgreementForm.js"}],"alternateClassNames":[],"members":{"method":[{"tagname":"method","meta":{},"owner":"PTS.controller.project.form.BaseModificationForm","name":"onDetailActivate","id":"method-onDetailActivate"},{"tagname":"method","meta":{},"owner":"PTS.controller.project.form.BaseModificationForm","name":"onDetailRowEdit","id":"method-onDetailRowEdit"},{"tagname":"method","meta":{},"owner":"PTS.controller.project.form.BaseModificationForm","name":"onItemLoad","id":"method-onItemLoad"},{"tagname":"method","meta":{},"owner":"PTS.controller.project.form.BaseModificationForm","name":"onNewItem","id":"method-onNewItem"},{"tagname":"method","meta":{},"owner":"PTS.controller.project.form.BaseModificationForm","name":"updateDetailStore","id":"method-updateDetailStore"}],"cfg":[],"property":[],"event":[],"css_var":[],"css_mixin":[]},"subclasses":[],"singleton":false,"code_type":"ext_define","inheritable":false,"superclasses":["PTS.controller.project.form.BaseModificationForm","PTS.controller.project.form.AgreementForm"],"component":false,"html":"<div><pre class=\"hierarchy\"><h4>Hierarchy</h4><div class='subclass first-child'><a href='#!/api/PTS.controller.project.form.BaseModificationForm' rel='PTS.controller.project.form.BaseModificationForm' class='docClass'>PTS.controller.project.form.BaseModificationForm</a><div class='subclass '><strong>PTS.controller.project.form.AgreementForm</strong></div></div><h4>Files</h4><div class='dependency'><a href='source/AgreementForm.html#PTS-controller-project-form-AgreementForm' target='_blank'>AgreementForm.js</a></div></pre><div class='doc-contents'><p>Controller for Agreement Form</p>\n</div><div class='members'><div class='members-section'><div class='definedBy'>Defined By</div><h3 class='members-title icon-method'>Methods</h3><div class='subsection'><div id='method-onDetailActivate' class='member first-child inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/PTS.controller.project.form.BaseModificationForm' rel='PTS.controller.project.form.BaseModificationForm' class='defined-in docClass'>PTS.controller.project.form.BaseModificationForm</a><br/><a href='source/BaseModificationForm.html#PTS-controller-project-form-BaseModificationForm-method-onDetailActivate' target='_blank' class='view-source'>view source</a></div><a href='#!/api/PTS.controller.project.form.BaseModificationForm-method-onDetailActivate' class='name expandable'>onDetailActivate</a>( <span class='pre'>Object grid</span> )</div><div class='description'><div class='short'>Update the activated roweditgrid store with current the modificationid. ...</div><div class='long'><p>Update the activated roweditgrid store with current the modificationid.</p>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>grid</span> : Object<div class='sub-desc'>\n</div></li></ul></div></div></div><div id='method-onDetailRowEdit' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/PTS.controller.project.form.BaseModificationForm' rel='PTS.controller.project.form.BaseModificationForm' class='defined-in docClass'>PTS.controller.project.form.BaseModificationForm</a><br/><a href='source/BaseModificationForm.html#PTS-controller-project-form-BaseModificationForm-method-onDetailRowEdit' target='_blank' class='view-source'>view source</a></div><a href='#!/api/PTS.controller.project.form.BaseModificationForm-method-onDetailRowEdit' class='name expandable'>onDetailRowEdit</a>( <span class='pre'>Object editor, Object e</span> )</div><div class='description'><div class='short'>Update the record in the roweditgrid store with the modificationid. ...</div><div class='long'><p>Update the record in the roweditgrid store with the modificationid.</p>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>editor</span> : Object<div class='sub-desc'>\n</div></li><li><span class='pre'>e</span> : Object<div class='sub-desc'>\n</div></li></ul></div></div></div><div id='method-onItemLoad' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/PTS.controller.project.form.BaseModificationForm' rel='PTS.controller.project.form.BaseModificationForm' class='defined-in docClass'>PTS.controller.project.form.BaseModificationForm</a><br/><a href='source/BaseModificationForm.html#PTS-controller-project-form-BaseModificationForm-method-onItemLoad' target='_blank' class='view-source'>view source</a></div><a href='#!/api/PTS.controller.project.form.BaseModificationForm-method-onItemLoad' class='name expandable'>onItemLoad</a>( <span class='pre'>Object model, Object form</span> )</div><div class='description'><div class='short'>Load the active roweditgrid, if any. ...</div><div class='long'><p>Load the active roweditgrid, if any. Clear the other stores.\nSet the statuscombo baseFilter.\nTODO: probably should use associations for this</p>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>model</span> : Object<div class='sub-desc'>\n</div></li><li><span class='pre'>form</span> : Object<div class='sub-desc'>\n</div></li></ul></div></div></div><div id='method-onNewItem' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/PTS.controller.project.form.BaseModificationForm' rel='PTS.controller.project.form.BaseModificationForm' class='defined-in docClass'>PTS.controller.project.form.BaseModificationForm</a><br/><a href='source/BaseModificationForm.html#PTS-controller-project-form-BaseModificationForm-method-onNewItem' target='_blank' class='view-source'>view source</a></div><a href='#!/api/PTS.controller.project.form.BaseModificationForm-method-onNewItem' class='name expandable'>onNewItem</a>( <span class='pre'>Object model, Object form</span> )</div><div class='description'><div class='short'>Disable the related details panel and clear any related grid stores. ...</div><div class='long'><p>Disable the related details panel and clear any related grid stores.</p>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>model</span> : Object<div class='sub-desc'>\n</div></li><li><span class='pre'>form</span> : Object<div class='sub-desc'>\n</div></li></ul></div></div></div><div id='method-updateDetailStore' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/PTS.controller.project.form.BaseModificationForm' rel='PTS.controller.project.form.BaseModificationForm' class='defined-in docClass'>PTS.controller.project.form.BaseModificationForm</a><br/><a href='source/BaseModificationForm.html#PTS-controller-project-form-BaseModificationForm-method-updateDetailStore' target='_blank' class='view-source'>view source</a></div><a href='#!/api/PTS.controller.project.form.BaseModificationForm-method-updateDetailStore' class='name expandable'>updateDetailStore</a>( <span class='pre'>Object store, Object id, Object uri</span> )</div><div class='description'><div class='short'>Update the roweditgrid store with the passed modificationid. ...</div><div class='long'><p>Update the roweditgrid store with the passed modificationid.</p>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>store</span> : Object<div class='sub-desc'>\n</div></li><li><span class='pre'>id</span> : Object<div class='sub-desc'>\n</div></li><li><span class='pre'>uri</span> : Object<div class='sub-desc'>\n</div></li></ul></div></div></div></div></div></div></div>","tagname":"class","mixins":[],"requires":[],"inheritdoc":null,"private":false,"name":"PTS.controller.project.form.AgreementForm","meta":{},"id":"class-PTS.controller.project.form.AgreementForm","aliases":{}});