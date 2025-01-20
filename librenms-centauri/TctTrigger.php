<?php

namespace LibreNMS\Snmptrap\Handlers;

use App\Models\Device;
use LibreNMS\Interfaces\SnmptrapHandler;
use LibreNMS\Snmptrap\Trap;
use Log;

class TctTrigger implements SnmptrapHandler
{
    /**
     * Handle snmptrap.
     * Data is pre-parsed and delivered as a Trap.
     *
     * @param  Device  $device
     * @param  Trap  $trap
     * @return void
     */
    public function handle(Device $device, Trap $trap)
    {
		$message = '';
        $load1MinMessage  = $trap->getOidData('UCD-SNMP-MIB::laErrMessage.1');
        $load5MinMessage  = $trap->getOidData('UCD-SNMP-MIB::laErrMessage.2');
        $load15MinMessage = $trap->getOidData('UCD-SNMP-MIB::laErrMessage.3');
        $diskMessage = $trap->getOidData('UCD-SNMP-MIB::dskErrorMsg.1');

		if (!empty($load1MinMessage)) {
			$message =    $load1MinMessage;
		} else if (!empty($load5MinMessage)) {
			$message =    $load5MinMessage;
		} else if (!empty($load15MinMessage)) {
			$message =    $load15MinMessage;
		} else if (!empty($diskMessage)) {
			$message = 'Filesystem ' . $diskMessage;
		} else {
			$message = $trap->toString(true);
		}

        Log::event('TCT: ' . $message, $device->device_id, 'trap', 4);
    }
}
