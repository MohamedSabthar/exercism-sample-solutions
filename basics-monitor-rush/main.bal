function allocateCubicles(int[] requests) returns int[] {
    map<int> allocation = {};
    foreach int request in requests {
        if request > 0 && request < 66 {
            allocation[request.toString()] = request;
        }
    }
    return allocation.toArray().sort();
}
