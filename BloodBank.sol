// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/**
 * @title BloodBank
 * @dev A smart contract for managing blood transactions and patient records in a blood bank.
 */
contract BloodBank {
    // set the owner of the contract
    address owner;

    constructor() {
        owner = msg.sender;
    }

    // Used for defining PatientType
    enum PatientType {
        Donor,
        Receiver
    }

    // Used to storing blood txn
    struct BloodTransaction {
        PatientType patientType;
        uint256 time;
        address from;
        address to;
    }

    // Used for storing single Patient records
    struct Patient {
        uint256 aadhar;
        string name;
        uint256 age;
        string bloodGroup;
        uint256 contact;
        string homeAddress;
        BloodTransaction[] bT;
    }

    // Array to store all the patient records
    // Array is used so that all the patient records can be fetched at once
    Patient[] PatientRecord;

    // Mapping is used to map the Aadhar card with the index number of the array where patient record is stored
    // This will prevent the use of loop in the contract
    mapping(uint256 => uint256) PatientRecordIndex;

    // Event used for notifying if a function is executed or not
    event Successfull(string message);

    /**
     * @dev Registers a new patient.
     * @param _name The name of the patient.
     * @param _age The age of the patient.
     * @param _bloodGroup The blood group of the patient.
     * @param _contact The contact number of the patient.
     * @param _homeAddress The home address of the patient.
     * @param _aadhar The Aadhar number of the patient.
     */
    function newPatient(
        string memory _name,
        uint256 _age,
        string memory _bloodGroup,
        uint256 _contact,
        string memory _homeAddress,
        uint256 _aadhar
    ) external {
        // Since a patient can only be registered by the hospital, it is required to check if the sender is the owner or not
        require(msg.sender == owner, "Only the admin can register a new patient");

        // Get the length of the array
        uint256 index = PatientRecord.length;

        // Insert the patient records
        PatientRecord.push();
        PatientRecord[index].name = _name;
        PatientRecord[index].age = _age;
        PatientRecord[index].bloodGroup = _bloodGroup;
        PatientRecord[index].contact = _contact;
        PatientRecord[index].homeAddress = _homeAddress;
        PatientRecord[index].aadhar = _aadhar;

        // Store the array index in the map against the user's Aadhar number
        PatientRecordIndex[_aadhar] = index;

        emit Successfull("Patient added successfully");
    }

    /**
     * @dev Gets the patient record for a specific Aadhar number.
     * @param _aadhar The Aadhar number of the patient.
     * @return The patient record.
     */
    function getPatientRecord(uint256 _aadhar)
        external
        view
        returns (Patient memory)
    {
        uint256 index = PatientRecordIndex[_aadhar];
        return PatientRecord[index];
    }

    /**
     * @dev Gets all the patient records stored in the contract.
     * @return An array of all the patient records.
     */
    function getAllRecord() external view returns (Patient[] memory) {
        return PatientRecord;
    }

    /**
     * @dev Stores the blood transaction details for a patient.
     * @param _aadhar The Aadhar number of the patient.
     * @param _type The type of patient (Donor or Receiver).
     * @param _from The address of the blood transaction sender.
     * @param _to The address of the blood transaction receiver.
     */
    function bloodTransaction(
        uint256 _aadhar,
        PatientType _type,
        address _from,
        address _to
    ) external {
        // Check if the sender is the hospital or not
        require(
            msg.sender == owner,
            "Only the hospital can update the patient's blood transaction data"
        );

        // Get the index at which the patient registration details are saved
        uint256 index = PatientRecordIndex[_aadhar];

        // Insert the BloodTransaction in the patient's record
        BloodTransaction memory txObj = BloodTransaction({
            patientType: _type,
            time: block.timestamp,
            from: _from,
            to: _to
        });

        PatientRecord[index].bT.push(txObj);

        // Note: The above statement can also be written as below:
        // PatientRecord[index].bT.push(BloodTransaction(_type, block.timestamp, _from, _to));

        emit Successfull(
            "Patient blood transaction data is updated successfully"
        );
    }
}
