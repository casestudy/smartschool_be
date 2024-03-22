//Useful functions
export default {
    sendErrorMessage: function(procedure, code, message) {
        let tmp = JSON.stringify(message);
        message = message.replaceAll("\"","'");
        return '{"error":{"proc":"'+procedure+'","code":"'+code+'","msg":"'+message+'"}}';
    },

    sendErrorMessages2: function(procedure, code, message) {
        let tmp = JSON.stringify(message);
        message = message.replaceAll("\"","'");
        return '{"error":{"proc":"'+procedure+'","code":"'+code+'","msg":"'+message+'"}}';
    },

    sendSuccessMessage: function() {
        return '{"error":false, "result":{"status":200, "value":"ok"}}';
    }
}