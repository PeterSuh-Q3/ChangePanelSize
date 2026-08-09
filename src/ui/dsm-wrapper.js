// Register Change Panel Size as a DSM-managed floating desktop window.
// The iframe keeps the existing UI unchanged while DSM supplies window
// controls (resize, minimize, maximize) rather than opening a bare URL tab.
Ext.ns('PeterSuh.ChangePanelSize');

Ext.define('PeterSuh.ChangePanelSize.AppInstance', {
    extend: 'SYNO.SDS.AppInstance',
    appWindowName: 'PeterSuh.ChangePanelSize.AppWindow',
    constructor: function () {
        this.callParent(arguments);
    },
});

Ext.define('PeterSuh.ChangePanelSize.AppWindow', {
    extend: 'SYNO.SDS.AppWindow',
    constructor: function (config) {
        const cfg = Ext.apply({
            resizable: true,
            maximizable: true,
            minimizable: true,
            width: 900,
            height: 650,
            minWidth: 600,
            minHeight: 400,
            layout: 'fit',
            border: false,
            items: [{
                xtype: 'box',
                autoEl: {
                    tag: 'iframe',
                    src: '/webman/3rdparty/Changepanelsize/index.html',
                    frameborder: '0',
                    style: 'width:100%; height:100%; border:none;',
                },
            }],
        }, config);
        this.callParent([cfg]);
    },
    onOpen: function (info) {
        this.callParent([info]);
    },
    onRequest: function (info) {
        this.onOpen(info);
    },
});
