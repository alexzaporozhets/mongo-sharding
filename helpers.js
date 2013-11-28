function checkReplicationStatus() {
    rs.status().members.forEach(replica)
    {
        if ([1, 2].indexOf(replica.status) == -1) {
            checkReplicationStatus();
        }
    }
    return true;
}
