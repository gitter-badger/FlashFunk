package example
{
	public class Player extends Gentity 
	{
		public function Player(_host:GenWorld, _x:Number=0.0, _y:Number=0.0) {
			// could be in a manually called init() function
			// so everything doesn't have to take the same arguments
			super(_host, _x, _y);
		}
		
		override public function scriptinit():void {
			// this movement script only inputs dx/dy - you apply them separately
			// for example, axis separation makes tile aligning easier
			var mvmt:ScriptPlatformerMovement = add_script(new ScriptPlatformerMovement()) as ScriptPlatformerMovement;

			// script order matters
			always(movex);
			add_script(new ScriptCollision("solid", alignx));
			always(movey);
			add_script(new ScriptCollision("solid", aligny));
			
			function end(msg:String):void {
				remove_script(timer);
				remove_script_type("movement");
				remove_script_type("collision");
				
				host.track.announce(msg);
				host.track.reset(140);

				always(function():void { 
					dx /= mvmt.slow; dy /= mvmt.slow;
				});
			}
			
			add_script(new ScriptCollision("collectible", function(hit:Gentity):void {
				hit.die();
				timer.delay += 75;
				
				// the count doesn't immediately change when removing from world
				// this could be in a 'when' script, but you'd have to check on every frame
				if (host.counttype("collectible") == 1) {
					end("clear");
				}
			}));

			add_script(new ScriptRotate(2.2));
			
			// doesn't matter that the timer and stop scripts have circular dependency
			// because of closure scope
			var timer:ScriptDelay = delay(125, function():void {
				end("time out");
			});
			
			write(0, 0, function():String {
				return timer.delay.toString();
			});
			
			// note that the trigger script only happens once in contrast to autoscripts
			when(function():Boolean {
				return x < 0 || x+width > host.track.scr_w;
			}, 
			die);
			
			// basically the same as an 'always' with a conditional
			whenever(function():Boolean {
				return y > host.track.scr_h;
			}, 
			function():void { y = 0; } );
		}
		
		override public function die():void {
			host.remove(this);
			host.track.announce("whoops");
			host.track.reset(140);
		}
	}
	
}